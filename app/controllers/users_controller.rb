class UsersController < ApplicationController
  layout "sessions"

  skip_before_filter :login_required
  before_filter :new_user

  def create
    if @user.update_attributes(params[:user])
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
