class CreateResponses < ActiveRecord::Migration[5.0]
  def change
    create_table :responses do |t|
		t.string :text
		t.integer :counter
		t.timestamps
    end
  end
end
