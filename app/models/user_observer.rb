class UserObserver < ActiveRecord::Observer
  def after_create(user)
    unless user.verified?
      UserMailer.deliver_verification(user)
    end
  end
end