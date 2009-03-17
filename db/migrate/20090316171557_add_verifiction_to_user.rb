class AddVerifictionToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :verified, :boolean
    add_column :users, :verification_token, :string
  end

  def self.down
    remove_column :users, :verification_token
    remove_column :users, :verified
  end
end
