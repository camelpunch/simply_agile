class MoveAcknowledgementTokenFromUserToOrganisationMember < ActiveRecord::Migration
  def self.up
    add_column :organisation_members, :acknowledgement_token, :string
    remove_column :users, :acknowledgement_token
  end

  def self.down
    add_column :users, :acknowledgement_token, :string
    remove_column :organisation_members, :acknowledgement_token
  end
end
