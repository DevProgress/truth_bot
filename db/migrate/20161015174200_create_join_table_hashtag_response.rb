class CreateJoinTableHashtagResponse < ActiveRecord::Migration[5.0]
  def change
    create_join_table :hashtags, :responses do |t|
      # t.index [:hashtag_id, :response_id]
      # t.index [:response_id, :hashtag_id]
			t.timestamps
    end
  end
end
