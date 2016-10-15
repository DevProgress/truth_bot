class TwitterApi
  require 'tweetstream'

  def stream(query)
    # USE TWEETSTREAM FOR NOW SINCE THE TWITTER GEM 
    # ADVISES AGAINST THEIR STREAMING CLIENT UNTIL VERSION 6
    # stream_client.filter(track: query) # twitter gem, takes a string
    Rails.logger.info("start stream #{query}")
    # tweetstream gem, takes an array
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

  def tweet(text, options = {})
    screen_name = options.delete(:screen_name)
    return false unless screen_name.present?

    sent_tweets = []
    for tweet in TwitterApi.split_tweets(text, screen_name)
      tweet_text = "@#{screen_name} - #{tweet}"
      rest_client.update(tweet_text, options)
      sent_tweets << tweet_text
    end

    return sent_tweets
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
    @rest_client ||= Twitter::REST::Client.new({consumer_key: ENV["TWITTER_API_KEY"], consumer_secret: ENV["TWITTER_API_SECRET"], access_token: ENV["TWITTER_ACCESS_TOKEN"], access_token_secret: ENV["TWITTER_ACCESS_TOKEN_SECRET"]})
  end

  private
  
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