require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/users/new" do
  before(:each) do
    @user = User.new
    assigns[:user] = @user
    render 'users/new'
  end

  it_should_behave_like "a standard view"
end
