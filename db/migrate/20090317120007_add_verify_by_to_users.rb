class AddVerifyByToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :verify_by, :date
  end

  def self.down
    remove_column :users, :verify_by
  end
end
