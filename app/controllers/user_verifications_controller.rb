class UserVerificationsController < ApplicationController
  skip_before_filter :login_required
  skip_before_filter :select_organisation
  before_filter :get_user

  layout 'landing'

  def new
  end

  def create
    if @user.verify(params)
      session[:user_id] = @user.id
      flash[:notice] = "Your account has now been verified."
      redirect_to root_url
    else
      flash.now[:error] = "The verification token has not been recognised."
      render :action => 'new'
    end
  end

  protected

  def get_user
    @user = User.find(params[:user_id])
  end
end
