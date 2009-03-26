class OrganisationsController < ApplicationController
  skip_before_filter :select_organisation, :only => [:index]
  
  before_filter :get_organisations, :only => [:index]
  before_filter :get_organisation, :only => [:show]
  before_filter :new_user

  def index
    
  end

  protected

  def new_user
    @user = User.new
  end

  def get_organisations
    @organisations = current_user.organisations
  end

  def get_organisation
    @organisation = current_organisation
  end
end
