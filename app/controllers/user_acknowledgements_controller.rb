class UserAcknowledgementsController < ApplicationController
  skip_before_filter :login_required
  skip_before_filter :select_organisation
  before_filter :get_user

  layout 'landing'

  def create
    if @user.acknowledge(params)
      session[:user_id] = @user.id
      redirect_to root_url
    else
      flash.now[:error] = 
      'Token not found - please check your latest acknowledgement email'
      render :action => 'new'
    end
  end

  protected

  def get_user
    @user = User.find(params[:user_id])
    @user.signup = true
  end
end
