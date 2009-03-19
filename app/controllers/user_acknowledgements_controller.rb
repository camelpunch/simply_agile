class UserAcknowledgementsController < ApplicationController
  skip_before_filter :login_required
  before_filter :get_user

  layout 'sessions'

  def create
    if @user.acknowledge(params)
      session[:user_id] = @user.id
      redirect_to root_url
    else
      render :action => 'new'
    end
  end

  protected

  def get_user
    @user = User.find(params[:user_id])
  end
end
