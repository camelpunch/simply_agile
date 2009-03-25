class AddSponsorIdToOrganisationMember < ActiveRecord::Migration
  def self.up
    add_column :organisation_members, :sponsor_id, :integer
  end

  def self.down
    remove_column :organisation_members, :sponsor_id
  end
end
