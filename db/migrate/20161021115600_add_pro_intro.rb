class AddProIntro < ActiveRecord::Migration[5.0]
  def change
    add_column :intro_phrases, :pro_hillary, :boolean, default: false
    add_column :topics, :pro_hillary, :boolean, default: false
  end
end
