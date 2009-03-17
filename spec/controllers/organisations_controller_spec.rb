require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe OrganisationsController do
  before :each do
    login
  end

  describe "creating a new user" do
    it "should assign a new user as an instance variable" do
      @user = User.new
      User.should_receive(:new).and_return(@user)
      controller.send(:new_user)
      controller.instance_variable_get("@user").should == @user
    end
  end
  
  describe "GET 'show'" do
    def do_call
      get :show, :id => 1
      
    end
    
    it_should_behave_like "it's successful"

    it "should assign the organisation" do
      controller.should_receive(:get_organisation)
      do_call
    end

    it "should assign a new user" do
      controller.should_receive(:new_user)
      do_call
    end
  end
end
