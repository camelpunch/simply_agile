require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/organisations/show" do
  before(:each) do
    users = []
    users << mock_model(
      User,
      :email_address => 'user@jandaweb.com',
      :acknowledged? => true
    )
    @organisation = mock_model(Organisation, :name => 'Jandaweb', :users => users)
    assigns[:organisation] = @organisation
    assigns[:user] = User.new
    render 'organisations/show'
  end

  it_should_behave_like "a standard view"
end
