class VerificationNotificationsController < ApplicationController
  skip_before_filter :login_required
  skip_before_filter :select_organisation

  layout 'landing'

  def create
    unverified_user = 
      User.find_by_email_address_and_verified!(params[:user][:email_address],
                                               false)

    UserMailer.deliver_verification(unverified_user)

    flash[:notice] = "Verification email sent"
    redirect_to new_user_verification_path(unverified_user)

  rescue ActiveRecord::RecordNotFound
    flash[:notice] = "You are already verified. 
                      Please log in with your username and password."
    redirect_to new_session_url
  end

end
