class OrganisationsController < ApplicationController
  skip_before_filter :select_organisation
  skip_before_filter :prevent_suspended_organisation_access
  
  before_filter :current_organisation
  before_filter :get_organisations, :only => [:index]
  before_filter :get_organisation, :only => [:edit, :update]
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

  def update
    if @organisation.update_attributes(params[:organisation])
      redirect_to :organisations
    else
      render :template => 'organisations/edit'
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
    @organisation = current_user.organisations.find(params[:id])
  end

  def get_payment_plans
    @payment_plans = PaymentPlan.all
  end
end
