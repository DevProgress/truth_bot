namespace :twitter_stream do

  desc "Twitter Stream Observer"
  task :observe => :environment do
    TweetImporter.new("observe_stream").perform
    Rails.logger.info("Twitter stream rake task has been called. The observer should be starting.")
  end

end