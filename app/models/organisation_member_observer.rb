class OrganisationMemberObserver < ActiveRecord::Observer
  def after_create(organisation_member)
    if organisation_member.sponsor_id?
      UserMailer.deliver_acknowledgement(organisation_member)
    end
  end
end
