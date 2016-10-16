class CreatePhraseHashtags < ActiveRecord::Migration[5.0]
  def change
    create_table :phrase_hashtags do |t|
      t.references :topic
      t.string :text
      t.timestamps
    end
  end
end
