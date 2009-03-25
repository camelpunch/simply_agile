class UserMailer < ActionMailer::Base
  def verification(user)
    subject    'Please verify your Simply Agile account'
    recipients user.email_address
    from       '"SimplyAgile" <noreply@jandaweb.com>'
        
    body       :user => user
  end

  def acknowledgement(organisation_member)
    organisation = organisation_member.organisation
    user = organisation_member.user
    sponsor = organisation_member.sponsor
    token = organisation_member.acknowledgement_token

    subject    "You have been added to #{organisation.name}"
    recipients user.email_address
    from       '"SimplyAgile" <noreply@jandaweb.com>'

    body       :organisation => organisation, :user => user, 
      :sponsor => sponsor, :token => token
  end
end
