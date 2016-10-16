class CreateIntroPhrases < ActiveRecord::Migration[5.0]
  def change
    create_table :intro_phrases do |t|
      t.string :text
      t.timestamps
    end
  end
end
