require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/invoices/show" do
  before(:each) do
    assigns[:current_user] = Users.create_user!
    assigns[:invoice] = Invoices.create_invoice!
    render 'invoices/show'
  end

  it_should_behave_like "a standard view"
end
