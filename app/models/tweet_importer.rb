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

  def observe_stream(time_limit = 30.minutes)
    stop_at = Time.now + time_limit
    hashtags = Hashtag.active
    query = hashtags.map {|h| "#{h.phrase}"}
    
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
    tweet_hash = {}

    tweet_hash[:tweet_id] = tweet.id
    tweet_hash[:twitter_id] = tweet.user.try(:id_str)
    tweet_hash[:screen_name] = tweet.user.screen_name
    tweet_hash[:text] = tweet.text.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
    Rails.logger.debug("Found a tweet: #{tweet_hash.inspect}")
    TweetImporter.delay.reply_to_tweet(tweet_hash)
  end

  def self.reply_to_tweet(tweet)
    return false if tweet[:screen_name].to_s.downcase == "simpolfy"
    hashtags = Hashtag.active
    hashtags.each do |h|
      if tweet[:text].include? h.phrase
        @phrase = h
        break
      end
    end
    if @phrase
      twitter = TwitterApi.new
      rest_client = twitter.rest_client
      if rest_client
        reply = @phrase.response
        twitter.tweet(reply, {in_reply_to_status_id: tweet[:tweet_id], screen_name: tweet[:screen_name]}, rest_client)
        Rails.logger.debug("Replying to tweet with message: #{reply}")
        return reply
      else
        TweetImporter.delay(run_at: 1.minute.from_now).reply_to_tweet(tweet)
      end
    end
  end

  private

  def api
    @api ||= TwitterApi.new
  end

end