class CreateTwitterBots < ActiveRecord::Migration[5.0]
  def change
    create_table :twitter_bots do |t|
      t.string :key
      t.string :secret
      t.string :token
      t.string :token_secret
      t.integer :counter, default: 0
      t.boolean :active, default: true
      t.timestamps
    end
  end
end
