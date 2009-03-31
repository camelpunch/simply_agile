class PaymentMethodsController < ApplicationController
  before_filter :get_organisation
  before_filter :new_payment_method

  def create
    if @payment_method.save
      redirect_to [@current_organisation, @payment_method]
    end
  end

  protected

  def new_payment_method
    @payment_method = @organisation.build_payment_method(params[:payment_method])
  end

  def get_organisation
    @organisation = Organisation.find(params[:organisation_id])
  end
end
