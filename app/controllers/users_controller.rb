class UsersController < ApplicationController
  layout "sessions"

  skip_before_filter :login_required, :only => [:new, :create]
  skip_before_filter :select_organisation
  before_filter :current_organisation, :only => [:show]
  before_filter :new_user, :only => [:new, :create]

  def show
    if params[:id].to_i != current_user.id
      redirect_to current_user 
    else
      render :layout => 'application'
    end
  end

  def create
    if @user.update_attributes(params[:user].merge(:signup => true))
      session[:user_id] = @user.id
      flash[:notice] = "Welcome to Simply Agile. To get started, create an organisation."
      redirect_to home_url
    else
      render :action => 'new'
    end
  end

  protected

  def new_user
    @user = User.new
  end
end
