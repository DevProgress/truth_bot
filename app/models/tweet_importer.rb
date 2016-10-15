class TweetImporter

  attr_reader :tweets

  def initialize(action = nil)
    @action = action
  end

  def perform
    @tweets = []

    if @action.present?
      self.send(@action.to_sym)
    end

    return "Tweet count: #{@tweets.length}"
  end

  def search_stream
    hashtags = Hashtag.active

    # The Twitter search function has a limit on number of keywords (< 10)
    hashtags.to_a.in_groups_of(8) do |tags|
      query = tags.compact.map {|h| "##{h.tag}"}.join(",")

      for tweet in api.search(query, 3)
        parse_tweet(tweet)
      end
    end

    # Send the rest and clear
    if @tweets.length > 0
      TweetImporter.delay(queue: 'tweets').record_tweets(@tweets)
      @tweets.clear
    end
  end

  def observe_stream(time_limit = 30.minutes)
    stop_at = Time.now + time_limit
    hashtags = Hashtag.active
    query = hashtags.map {|h| "##{h.phrase}"}
    
    Rails.logger.info("Starting to observe twitter stream...")
    

    api.stream(query) do |tweet|
      parse_tweet(tweet)

      if Time.now >= stop_at
        # Record any left overs
        TweetImporter.delay(queue: 'tweets').record_tweets(@tweets)
        @tweets.clear
        Rails.logger.info("Tweet importer hit time limit, resetting...")
        break
      end
    end

    observe_stream(30.minutes)
  end

  def parse_tweet(tweet)
    @tweets ||= []
    tweet_hash = {}

    tweet_hash[:tweet_id] = tweet.id
    tweet_hash[:twitter_id] = tweet.user.try(:id_str)
    tweet_hash[:screen_name] = tweet.user.screen_name
    tweet_hash[:hashtags] = tweet.hashtags.map {|h| h.text.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')}
    tweet_hash[:text] = tweet.text.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')

    Rails.logger.debug("Found a tweet: #{tweet_hash.inspect}")

    if @tweets.length == ENV["RECORD_TWEETS_IN_BATCHES_OF"].to_i
      TweetImporter.delay(queue: 'tweets').record_tweets(@tweets)
      Rails.logger.info("Batch recording #{@tweets.length} tweets")
      @tweets.clear
    end
  end

  def self.record_tweets(tweets)
    for tweet in tweets
      next if tweet[:screen_name].to_s.downcase == "simpolfy"

      Rails.logger.debug("Checking tweet: #{tweet.inspect}")

      login = Login.where(provider: 'twitter', uid: tweet[:twitter_id]).first
      user = login.try(:user)
      hashtag_votes = []

      for hashtag in Hashtag.active.where(tag: tweet[:hashtags])
        if hashtag.allow_soft_votes or tweet[:mentions_simpolfy] # soft votes currently disabled in parse_tweet()
          if tweet[:mentions_simpolfy]
            vote_type = 0
          else
            vote_type = 1
          end
          vote_added = hashtag.record_vote!('twitter', tweet[:twitter_id], tweet[:tweet_id], tweet[:text], user, nil, nil, nil, vote_type)
          
          if vote_added
            hashtag_votes << hashtag.tag
          else
            Rails.logger.debug("Vote failed; either duplicate or error; tweet: #{tweet.inspect}")
          end
        end
      end

      if hashtag_votes.any?
        Rails.logger.debug("Votes added for tweet: #{tweet.inspect}; Hashtags: #{hashtag_votes.inspect}")
      else
        Rails.logger.debug("Votes skipped or already recorded for tweet: #{tweet.inspect}")
      end

      if hashtag_votes.any? and tweet[:mentions_simpolfy] and Rails.env.production? and ENV["REPLY_TO_TWEETS"] == "true"
        TweetImporter.delay(queue: 'tweets').reply_to_tweet!(tweet, user.try(:id))
        Rails.logger.debug("Replying to tweet: #{tweet.inspect}")
      end
    end
  end

  def self.reply_to_tweet!(tweet, user_id = nil, ignore_env = false)
    for tweet in tweets
      return false if tweet[:screen_name].to_s.downcase == "simpolfy"

      hashtags = Hashtag.active.where(tag: tweet[:hashtags])

      if user_id
        user = User.find(user_id)

        short_response = hashtags.map {|h| h.response}.to_sentence

        reply = "we got your vote " + short_response + "! "

        hashtag = hashtags.first
        reply = reply + hashtag.issue_politicians_response(user,'Twitter').to_s
        reply = reply + "http://www.simpolfy.com" + hashtag.source_path

      elsif hashtags.order("guest_response DESC").first.try(:guest_response).present?
        reply = hashtags.order("guest_response DESC").first.try(:guest_response)
      else
        tags = tweet[:hashtags].to_sentence
        reply = "thanks for voting on #{tags}! Signup on Simpolfy.com if you want it to count in the tally."
      end

      if (Rails.env.production? or ignore_env) and reply.present?
        TwitterApi.new.tweet(reply, {in_reply_to_status_id: tweet[:tweet_id], screen_name: tweet[:screen_name]})
        Rails.logger.debug("Replying to tweet with message: #{reply}")
      end
    end

    return reply
  end

  private

  def api
    @api ||= TwitterApi.new
  end

end