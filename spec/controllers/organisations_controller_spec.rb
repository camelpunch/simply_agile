require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe OrganisationsController do
  before :each do
    login
  end

  describe "setting the organisation" do
    it "should get the organisation the current user" do
      @user.should_receive(:organisation)
      controller.send(:get_organisation)
    end

    it "should assign the instance variable" do
      controller.send(:get_organisation)
      controller.instance_variable_get("@organisation").should == @organisation
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
  end
end
