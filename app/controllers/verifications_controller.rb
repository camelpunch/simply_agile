class VerificationsController < ApplicationController
  skip_before_filter :login_required
  before_filter :get_user

  layout 'sessions'

  def new
  end

  def create
    if @user.verification_token == params[:token]
      @user.update_attributes(:verified => true)
      session[:user_id] = @user.id
      flash[:notice] = "Your account has now been verified."
      redirect_to root_url
    else
      flash[:notice] = "Your account has now been verified."
      render :action => 'new'
    end
  end

  protected

  def get_user
    @user = User.find(params[:user_id])
  end
end
