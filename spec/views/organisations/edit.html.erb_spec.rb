require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/organisations/edit" do
  before(:each) do
    assigns[:organisation] = mock_model Organisation, :name => ''
    assigns[:current_organisation] = mock_model Organisation
    assigns[:current_user] = mock_model User
    render 'organisations/edit'
  end

  it_should_behave_like "a standard view"
end
