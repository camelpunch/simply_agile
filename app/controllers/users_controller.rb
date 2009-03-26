class UsersController < ApplicationController
  layout "sessions"

  skip_before_filter :login_required
  skip_before_filter :select_organisation
  before_filter :new_user

  def create
    if @user.update_attributes(params[:user].merge(:signup => true))
      session[:user_id] = @user.id
      redirect_to root_url
    else
      render :action => 'new'
    end
  end

  protected

  def new_user
    @user = User.new
  end
end
