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
    @hashtag = nil
    hashtags.each do |h|
      if tweet[:text].include? h.phrase
        @hashtag = h
        break
      end
    end
    if @hashtag
      response = ShortURL.shorten(Response.where(topic_id: @hashtag.topic.id).order("RAND()").first.text)
      phrase_hashtag = PhraseHashtag.where(topic_id: @hashtag.topic.id).order("RAND()").first 
    end
    if @hashtag and response
      twitter = TwitterApi.new
      rest_client = twitter.rest_client
      if rest_client

        intro = IntroPhrase.where("pro_hillary is null or pro_hillary = #{@hashtag.topic.pro_hillary}").order("RAND()").first
        reply = "#{intro.text} #{response}"
        reply = reply + " ##{phrase_hashtag.text}" if phrase_hashtag
        tweet_data = twitter.tweet(reply, {in_reply_to_status_id: tweet[:tweet_id], screen_name: tweet[:screen_name]}, rest_client)
        Rails.logger.debug("Replied to tweet with message: #{reply} #{tweet_data.inspect}")
        if tweet_data
          new_tweet = Tweet.where(twitter: tweet_data.id).first_or_initialize
          new_tweet.user = tweet_data.user.screen_name
          new_tweet.text = tweet_data.text
          new_tweet.response_to_tweet = tweet[:tweet_id]
          new_tweet.response_to_user = tweet[:screen_name]
          new_tweet.save if new_tweet.new_record? or new_tweet.changed?
        end
        return reply
      else
        TweetImporter.delay(run_at: 1.minute.from_now).reply_to_tweet(tweet)
      end
    else
      Rails.logger.debug("No hashtag: #{tweet[:text]}") if !@hashtag
      Rails.logger.debug("No response: Topic #{@hashtag.topic.id}") if @hashtag and !response
    end
  end

  private

  def api
    @api ||= TwitterApi.new
  end

end