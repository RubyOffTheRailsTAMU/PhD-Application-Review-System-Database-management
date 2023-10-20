class Changeuserleveltostring < ActiveRecord::Migration[7.0]
  def change
    change_column :users, :user_netid, :string, null: false
    change_column :users, :user_name, :string, null: false
    change_column :users, :user_level, :string, null: false
  end
end
