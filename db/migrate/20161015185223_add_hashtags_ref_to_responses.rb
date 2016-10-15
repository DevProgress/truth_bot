class AddHashtagsRefToResponses < ActiveRecord::Migration[5.0]
  def change
    add_reference :responses, :hashtag, foreign_key: true
  end
end
