class CreateTopics < ActiveRecord::Migration[5.0]
  def change
    create_table :topics do |t|
      t.string :name
      t.timestamps
    end
    add_column :hashtags, :topic_id, :integer
    remove_foreign_key :responses, :hashtags
    remove_column :responses, :hashtag_id
    add_reference :responses, :topic
  end
end
