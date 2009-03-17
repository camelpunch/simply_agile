class UserObserver < ActiveRecord::Observer
  def after_create(user)
    UserMailer.deliver_verification(user)
  end
end