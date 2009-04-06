require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/payment_methods/index" do
  before(:each) do
    organisation = Organisations.create_organisation!
    organisation.next_payment_date = Date.today
    payment_method = 
      PaymentMethod.new(:organisation => organisation,
                        :year => 2.years.from_now.year,
                        :month => 1)
    payment_method.build_billing_address
    assigns[:payment_methods] = [payment_method]
    render 'payment_methods/index'
  end

  it_should_behave_like "a standard view"
end
