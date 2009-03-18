class OrganisationSponsor < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :user_id
  validates_associated :user

  belongs_to :sponsor, :class_name => 'User'
  validates_presence_of :sponsor_id
  validates_associated :sponsor

  belongs_to :organisation
  validates_presence_of :organisation_id
  validates_associated :organisation
end
