class OrganisationMember < ActiveRecord::Base
  include TokenGeneration

  attr_accessor :email_address

  belongs_to :user
  belongs_to :sponsor, :class_name => 'User'
  belongs_to :organisation

  validates_presence_of :user_id, :organisation_id
  validates_uniqueness_of :user_id, :scope => :organisation_id

  def before_create
    self.acknowledgement_token ||= generate_token
  end

  def validate
    if organisation
      errors.add(:organisation, "is suspended") if organisation.suspended?

      count = self.class.count(:conditions => {:organisation_id => organisation_id})
      if count >= organisation.payment_plan.user_limit
        errors.add(:organisation, "user limit reached")
      end
    end
  end
end
