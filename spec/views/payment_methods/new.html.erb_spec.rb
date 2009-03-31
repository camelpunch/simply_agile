require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/payment_methods/new" do
  before(:each) do
    assigns[:current_organisation] = Organisation.new
    payment_method = PaymentMethod.new
    payment_method.build_billing_address
    assigns[:payment_method] = payment_method
    render 'payment_methods/new'
  end

  it_should_behave_like "a standard view"
end
