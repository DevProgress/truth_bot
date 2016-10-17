class TwitterApi
  require 'tweetstream'

  def stream(query)
    # USE TWEETSTREAM FOR NOW SINCE THE TWITTER GEM 
    # ADVISES AGAINST THEIR STREAMING CLIENT UNTIL VERSION 6
    # stream_client.filter(track: query) # twitter gem, takes a string
    # tweetstream gem, takes an array
    Rails.logger.info(query)
    Rails.logger.info(YAML::dump(@tweetstream_client))
    tweetstream_client.track(query) do |tweet|
      Rails.logger.info(tweet)
      yield(tweet)
    end
  end

  def search(query, max_pages = 1)
    tweets = []
    current_page = 1
    results = nil

    while current_page <= max_pages
      options = {result_type: "recent", count: 100}
      options[:max_id] = results.last.try(:id) if results
      results = rest_client.search(query, options).to_a

      if results.any?
        tweets += results
      else
        break
      end

      current_page += 1
    end
    
    tweets
  end

  def tweet(text, options = {}, rest_c)
    screen_name = options.delete(:screen_name)
    return false unless screen_name.present?
    sent_tweets = []
    for tweet in TwitterApi.split_tweets(text, screen_name)
      tweet_text = "@#{screen_name} - #{tweet}"
      begin
        @response = rest_c.update(tweet_text, options)
      rescue Twitter::Error::Forbidden => e
        @twitter_bot.active = false
        @twitter_bot.save
        return false
      end
      sent_tweets << tweet_text
    end
    return @response
  end

  def self.split_tweets(text, screen_name)
    tweets = []
    length = screen_name.to_s.length + 4

    for word in text.split(" ")
      tweet_count = tweets.length
      index = tweet_count > 0 ? tweet_count - 1 : 0
      tweet = tweets[index].to_s

      if (tweet.length + word.length) > 140 - length
        tweets << word
      else
        tweet += " #{word}"
        tweets[index] = tweet.strip
      end
    end

    return tweets
  end

  def rest_client
    #@twitter_bot = TwitterBot.where("last_tweet < now() - interval #{[*25..30].sample} minute or last_tweet is NULL and active = TRUE").order("RAND()").first
    @twitter_bot = TwitterBot.first
    if @twitter_bot
      @rest_client = Twitter::REST::Client.new({consumer_key: @twitter_bot.key, consumer_secret: @twitter_bot.secret, access_token: @twitter_bot.token, access_token_secret: @twitter_bot.token_secret})
      @twitter_bot.increment(:counter)
      @twitter_bot.last_tweet = Time.now
      @twitter_bot.save if @twitter_bot.changed?
      return @rest_client
    else
      return false
    end
  end
  
  def stream_client
    @streaming_client ||= Twitter::Streaming::Client.new({consumer_key: ENV["TWITTER_API_KEY"], consumer_secret: ENV["TWITTER_API_SECRET"], access_token: ENV["TWITTER_ACCESS_TOKEN"], access_token_secret: ENV["TWITTER_ACCESS_TOKEN_SECRET"]})
  end

  def tweetstream_client
    return @tweetstream_client if @tweetstream_client

    TweetStream.configure do |config|
      config.consumer_key       = ENV["TWITTER_API_KEY"]
      config.consumer_secret    = ENV["TWITTER_API_SECRET"]
      config.oauth_token        = ENV["TWITTER_ACCESS_TOKEN"]
      config.oauth_token_secret = ENV["TWITTER_ACCESS_TOKEN_SECRET"]
      config.auth_method        = :oauth
    end

    @tweetstream_client = TweetStream::Client.new
  end

end