class CreateTweets < ActiveRecord::Migration[5.0]
  def change
    create_table :tweets do |t|
      t.string :twitter
      t.string :user
      t.string :text
      t.string :response_to_tweet
      t.string :response_to_user
      t.timestamps
    end
  end
end