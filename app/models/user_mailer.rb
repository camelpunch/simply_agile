class UserMailer < ActionMailer::Base
  def verification(user)
    subject    'Please verify your Simply Agile account'
    recipients user.email_address
    from       '"SimplyAgile" <noreply@jandaweb.com>'
        
    body       :user => user
  end

  def authorisation(user)
    subject    "You have been added to #{user.organisation.name}"
    recipients user.email_address
    from       '"SimplyAgile" <noreply@jandaweb.com>'

    body       :user => user,
      :sponsor => user.organisation_sponsors.first.sponsor
  end
end
