class VerificationNotificationsController < ApplicationController
  skip_before_filter :login_required
  skip_before_filter :select_organisation

  layout 'landing'

  def create
    user = User.find_by_email_address params[:user][:email_address]
    UserMailer.deliver_verification(user)
    flash[:notice] = "Verification Email Sent"
    redirect_to new_user_verification_path(user)
  end

end
