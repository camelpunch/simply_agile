class OrganisationsController < ApplicationController
  skip_before_filter :select_organisation, :only => [:index, :new, :create]
  
  before_filter :get_organisations, :only => [:index]
  before_filter :get_organisation, :only => [:show]
  before_filter :new_user
  before_filter :new_organisation, :only => :new
  before_filter :get_payment_plans, :only => :new

  protected

  def new_user
    @user = User.new
  end

  def new_organisation
    @organisation = Organisation.new
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
