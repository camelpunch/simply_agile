class OrganisationsController < ApplicationController
  skip_before_filter :select_organisation, :only => [:index, :new, :create]
  
  before_filter :get_organisations, :only => [:index]
  before_filter :get_organisation, :only => [:show]
  before_filter :new_organisation, :only => [:new, :create]
  before_filter :get_payment_plans, :only => :new

  def create
    if @organisation.update_attributes(params[:organisation])
      session[:organisation_id] = @organisation.id
      redirect_to home_url
    else
      get_payment_plans
      render :template => 'organisations/new'
    end
  end

  protected

  def new_organisation
    @organisation = Organisation.new :users => [current_user]
  end

  def get_organisations
    @organisations = current_user.organisations
  end

  def get_organisation
    @organisation = current_organisation
  end

  def get_payment_plans
    @payment_plans = PaymentPlan.all
  end
end
