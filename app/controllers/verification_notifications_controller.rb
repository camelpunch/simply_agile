class VerificationNotificationsController < ApplicationController
  skip_before_filter :login_required
  skip_before_filter :select_organisation

  layout 'landing'

  def create
    if params[:user][:email_address].blank?
      flash.now[:notice] = "Please enter your email address"
      render :new
      return
    end

    user = User.find_by_email_address!(params[:user][:email_address])

    if user.verified?
      flash[:notice] = "You are already verified. 
                        Please log in with your username and password."
      redirect_to new_session_url
    else
      UserMailer.deliver_verification(user)

      flash[:notice] = "Verification email sent"
      redirect_to new_user_verification_path(user)
    end

  rescue ActiveRecord::RecordNotFound
    flash[:notice] = "Email address not found"
    redirect_to new_session_url
  end

end
