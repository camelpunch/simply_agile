class UserObserver < ActiveRecord::Observer
  def after_create(user)
    if user.signup?
      UserMailer.deliver_verification(user)
    else
      UserMailer.deliver_acknowledgement(user)
    end
  end
end