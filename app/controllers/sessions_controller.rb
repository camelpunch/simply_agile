class SessionsController < ApplicationController
  skip_before_filter :login_required
  skip_before_filter :select_organisation
  skip_before_filter :prevent_suspended_organisation_access

  def create
    email_address = params[:user][:email_address]
    password = params[:user][:password]
    user = User.find_by_email_address_and_password(email_address, password)

    if user
      session[:user_id] = user.id
      do_redirect
    else
      flash.now[:notice] = "User and password not found. Please try again."
      render :template => 'sessions/new'
    end
  end

  def update
    organisation = Organisation.find(params[:organisation_id])

    if organisation.suspended?
      flash[:error] = "Organisation is suspended"
      redirect_to organisations_url
    else
      session[:organisation_id] = organisation.id
      do_redirect
    end
  end

  def destroy
    session[:user_id] = nil
    session[:organisation_id] = nil
    redirect_to root_url
  end

  protected

  def do_redirect
    stored_redirect_url = session[:redirect_to]
    if stored_redirect_url
      session[:redirect_to] = nil
      redirect_to stored_redirect_url
    else
      redirect_to home_url
    end
  end
end
