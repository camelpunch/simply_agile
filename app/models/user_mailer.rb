class UserMailer < ActionMailer::Base
  FROM_ADDRESS = '"SimplyAgile" <support@besimplyagile.com>'
  def verification(user)
    subject    'Please verify your Simply Agile account'
    recipients user.email_address
    from       FROM_ADDRESS
        
    body       :user => user
  end

  def acknowledgement(organisation_member)
    organisation = organisation_member.organisation
    user = organisation_member.user
    sponsor = organisation_member.sponsor
    token = organisation_member.acknowledgement_token

    subject    "You have been added to #{organisation.name}"
    recipients user.email_address
    from       FROM_ADDRESS

    body       :organisation => organisation, :user => user, 
      :sponsor => sponsor, :token => token
  end

  def payment_failure(organisation)
    payment_method = organisation.payment_method
    user = payment_method.user

    subject    "Payment failed for #{organisation.name}"
    recipients user.email_address
    from       FROM_ADDRESS

    body       :organisation => organisation, :user => user,
      :payment_method => payment_method
  end
end
