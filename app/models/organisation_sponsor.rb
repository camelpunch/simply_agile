class OrganisationSponsor < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :user_id

  belongs_to :sponsor, :class_name => 'User'
  validates_presence_of :sponsor_id

  belongs_to :organisation
  validates_presence_of :organisation_id
end
