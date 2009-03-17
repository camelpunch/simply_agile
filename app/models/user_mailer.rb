class UserMailer < ActionMailer::Base
  

  def verification(user)
    subject    'Please authorize your Simply Agile account'
    recipients user.email_address
    from       '"SimplyAgile" <noreply@jandaweb.com>'
        
    body       :user => user
  end

end
