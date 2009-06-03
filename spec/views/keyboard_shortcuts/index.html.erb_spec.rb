require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/keyboard_shortcuts/index" do
  before(:each) do
    assigns[:current_user] = mock_model User
    assigns[:current_organisation] = mock_model Organisation
    render 'keyboard_shortcuts/index'
  end
  
  it_should_behave_like "a standard view"
end
