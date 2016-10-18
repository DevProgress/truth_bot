class AddTwitterNameToBots < ActiveRecord::Migration[5.0]
  def change
    add_column :twitter_bots, :twitter_handle, :string 
  end
end
