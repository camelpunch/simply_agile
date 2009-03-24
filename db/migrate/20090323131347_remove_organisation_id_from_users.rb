class RemoveOrganisationIdFromUsers < ActiveRecord::Migration
  def self.create_organisation_memberships
    User.find(:all, :conditions => 'organisation_id IS NOT NULL').each do |user|
      if user.organisation_id
        OrganisationMembership.create!(
          :user_id => user.id,
          :organisation_id => user.organisation_id
        )
      end
    end
  end

  def self.up
    create_organisation_memberships
    remove_column(:users, :organisation_id)
  end

  def self.set_organisation_ids
    OrganisationMembership.all.each do |membership|
      user = User.find(membership.user_id)
      user.update_attribute(:organisation_id, membership.organisation_id)
    end
  end

  def self.down
    add_column(:users, :organisation_id, :integer)
    set_organisation_ids
  end
end
