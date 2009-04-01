require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/users/show" do
  before(:each) do
    assigns[:current_user] = mock_model(User)
    render 'users/show'
  end

  it_should_behave_like "a standard view"
end
