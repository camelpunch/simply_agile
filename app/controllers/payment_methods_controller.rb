class PaymentMethodsController < ApplicationController
  before_filter :get_organisation, :only => [:new, :create]
  before_filter :new_payment_method, :only => [:new, :create]
  before_filter :get_payment_method, :only => [:destroy]

  def index
    @payment_methods = @current_user.payment_methods
    if @current_user.payment_methods.empty?
      render :template => 'payment_methods/index_guidance'
    end
  end

  def create
    if @payment_method.save
      redirect_to :payment_methods
    else
      render :template => 'payment_methods/new'
    end
  end

  def destroy
    @payment_method.destroy
    flash[:notice] = "Payment cancelled"
    redirect_to :payment_methods
  end

  protected

  def get_payment_method
    @payment_method = @current_user.payment_methods.find(params[:id])
  end

  def new_payment_method
    @payment_method = @current_user.payment_methods.
      build(params[:payment_method])
    @payment_method.organisation = @current_organisation

    @payment_method.build_billing_address :country => "United Kingdom"

    if (params[:payment_method] &&
        params[:payment_method][:billing_address_attributes])
      @payment_method.billing_address.attributes = 
        params[:payment_method][:billing_address_attributes]
    end
  end

  def get_organisation
    @organisation = @current_user.organisations.find(params[:organisation_id])
  end
end
