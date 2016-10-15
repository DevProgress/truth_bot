web: bundle exec unicorn -p $PORT -c ./config/unicorn.rb
tweetstream: bundle exec rake twitter_stream:observe
worker: bundle exec rake jobs:work