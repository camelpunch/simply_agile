class AddAcknowledgementTokenToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :acknowledgement_token, :string
  end

  def self.down
    remove_column :users, :acknowledgement_token
  end
end
