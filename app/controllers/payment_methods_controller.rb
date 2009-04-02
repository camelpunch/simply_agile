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
      redirect_to [@current_organisation, @payment_method]
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
    @payment_method = @organisation.build_payment_method(params[:payment_method])
    @payment_method.build_billing_address
  end

  def get_organisation
    @organisation = Organisation.find(params[:organisation_id])
  end
end
