class OrganisationMember < ActiveRecord::Base
  include TokenGeneration

  belongs_to :user
  belongs_to :sponsor, :class_name => 'User'
  belongs_to :organisation

  def before_create
    self.acknowledgement_token ||= generate_token
  end
end
