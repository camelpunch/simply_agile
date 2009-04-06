require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/invoices/index" do
  before(:each) do
    assigns[:invoices] = [Invoices.create_invoice!]
    render 'invoices/index'
  end
  
  it_should_behave_like "a standard view"
end
