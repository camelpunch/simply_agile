require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/organisations/new" do
  before(:each) do
    assigns[:organisation] = Organisation.new
    assigns[:payment_plans] = [PaymentPlans.create_payment_plan!]
    render 'organisations/new'
  end

  it_should_behave_like "a standard view"
end
