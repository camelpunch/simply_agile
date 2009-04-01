require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/organisation_members/index" do
  before(:each) do
    users = []
    users << mock_model(
      User,
      :email_address => 'user@jandaweb.com',
      :acknowledged_for? => true
    )
    members = []
    members << mock_model(OrganisationMember, :user => users.first)
    @organisation = mock_model(Organisation, 
                               :name => 'Jandaweb', 
                               :members => members,
                               :users => users)
    assigns[:organisation] = @organisation
    assigns[:organisation_member] = OrganisationMember.new
    assigns[:user] = User.new
  render 'organisation_members/index'
  end

  it_should_behave_like "a standard view"
end
