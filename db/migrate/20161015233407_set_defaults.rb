class SetDefaults < ActiveRecord::Migration[5.0]
  def up
    change_column :responses, :counter, :integer, default: 0
    remove_column :hashtags, :response
    change_column :users, :role, :integer, default: 0
  end

  def down
    add_column :hashtags, :response, :string
  end
end
