class PaymentMethodsController < ApplicationController
  before_filter :get_organisation
  before_filter :new_payment_method

  def create
    if @payment_method.save
      redirect_to [@current_organisation, :payment_method]
    end
  end

  protected

  def new_payment_method
    @payment_method = PaymentMethod.new(params[:payment_method])
    @payment_method.organisation = @organisation
    @payment_method.build_billing_address :country => "United Kingdom"
  end

  def get_organisation
    @organisation = Organisation.find(params[:organisation_id])
  end
end
