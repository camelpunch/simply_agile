require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe OrganisationsController do
  before :each do
    login
    session[:organisation_id] = nil
  end

  describe "GET index" do
    def do_call
      get :index
    end

    it "should assign the user's organisations" do
      do_call
      assigns[:organisations].should == @user.organisations
    end

  end
  
  describe "GET 'show'" do
    def do_call
      get :show, :id => 1
      
    end
    
    it_should_behave_like "it's successful"

    it "should assign the organisation" do
      do_call
      assigns[:organisation].should == @organisation
    end

    it "should assign a new user" do
      do_call
      assigns[:user].should be_kind_of(User)
      assigns[:user].should be_new_record
    end
  end
end
