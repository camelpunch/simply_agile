class AddAuthorisedToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :authorised, :boolean
  end

  def self.down
    remove_column :users, :authorised
  end
end
