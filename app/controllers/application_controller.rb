class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  layout :decide_layout

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'a06ef3d2087744dfb53f6628410ad34b'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  filter_parameter_logging :password

  before_filter :login_required

  protected

  def current_user
    @current_user ||= User.valid.find_by_id(session[:user_id])
  end

  def decide_layout
    layout = ''
    respond_to do |format|
      format.html do
        layout = 'application'
      end

      format.js do
        layout = 'request'
      end
    end

    layout
  end

  def get_organisation
    @organisation = current_user.organisation
  end

  def get_project
    if params[:project_id]
      @project = current_user.organisation.projects.find(params[:project_id])
    end
  end

  def login_required
    if current_user
      true
    else
      flash[:notice] = "Please log in to continue"
      session[:redirect_to] = request.referer
      redirect_to new_session_url
    end
  end
end
