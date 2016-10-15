class AddLastTweet < ActiveRecord::Migration[5.0]
  def change
    add_column :twitter_bots, :last_tweet, :datetime
  end
end
