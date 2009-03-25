class OrganisationMemberObserver < ActiveRecord::Observer
  def after_create(organisation_member)
    UserMailer.deliver_acknowledgement(organisation_member)
  end
end
