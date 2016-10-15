class CreateHashtags < ActiveRecord::Migration[5.0]
  def change
    create_table :hashtags do |t|
      t.string :phrase
      t.string :response
      t.boolean :active
      t.timestamps
    end
  end
end
