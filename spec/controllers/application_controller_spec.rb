require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'ostruct'

describe ApplicationController do
  
  before :each do
    @user = mock_model User
    @request_uri = '/some/place'
  end

  describe "current_user" do
    before :each do
      @incorrect_id = 314123
      @valid_users = mock('Collection')
      @valid_users.stub!(:find_by_id).with(@user.id).and_return(@user)
      @valid_users.stub!(:find_by_id).with(nil).and_return(nil)
      @valid_users.stub!(:find_by_id).with(@incorrect_id).and_return(nil)
      User.stub!(:valid).and_return(@valid_users)
    end

    it "should assign the user" do
      @valid_users.stub!(:find_by_id).and_return(@user)
      controller.send(:current_user)
      controller.instance_variable_get('@current_user').should == @user
    end

    it "should memoize" do
      @valid_users.stub!(:find_by_id).and_return(@user)
      controller.send(:current_user)
      User.should_not_receive(:find_by_id)
      controller.send(:current_user)
    end

    describe "with logged in user" do
      before :each do
        session[:user_id] = @user.id
      end

      it "should return the user" do
        controller.send(:current_user).should == @user
      end
    end

    describe "with incorrect session user id" do
      before :each do
        session[:user_id] = @incorrect_id
      end

      it "should return nil" do
        controller.send(:current_user).should be_nil
      end
    end

    describe "without logged in user" do
      before :each do
        session[:user_id] = nil
      end

      it "should return nil" do
        controller.send(:current_user).should be_nil
      end
    end
  end

  describe "current_organisation" do
    before(:each) do
      login
    end

    describe "with a current organisation set" do
      before :each do
        @organisation = @user.organisations.first
        @organisation.should_not be_nil
        session[:organisation_id] = @organisation.id
      end

      it "should return the organisation" do
        controller.send(:current_organisation).should == @organisation
      end

      it "should assign an instance variable" do
        controller.send(:current_organisation)
        controller.instance_variable_get("@current_organisation").should ==
          @organisation
      end
    end

    describe "with an invalid current organisation" do
      before :each do
        @organisation_for_other_user = Organisations.create_organisation!
        session[:organisation_id] = @organisation_for_other_user.id
      end

      it "should return nil" do
        controller.send(:current_organisation).should be_nil
      end

      it "should not set an instance variable" do
        controller.send(:current_organisation)
        controller.instance_variable_get("@current_organisation").should be_nil
      end
    end
    
    describe "with no current organisation set" do
      before :each do
        session[:organisation_id] = nil
      end
      
      it "should return nil" do
        controller.send(:current_organisation).should be_nil
      end
      
      it "should not set an instance variable" do
        controller.send(:current_organisation)
        controller.instance_variable_get("@current_organisation").should be_nil
      end
    end
  end

  describe "get_project" do
    before :each do
      login
      @project = Projects.create_project!(:organisation => @organisation)
    end

    it "should restrict to user's projects" do
      controller.stub!(:params).and_return({:project_id => @project.id.to_s})
      controller.send(:get_project)
      controller.instance_variable_get("@project").should == @project
    end

    it "should not find if there's no params[:project_id]" do
      controller.stub!(:params).and_return({})
      @user.should_not_receive(:organisation)
      controller.send(:get_project)
    end
  end

  describe "login_required" do
    describe "with logged in user" do
      before :each do
        controller.stub!(:current_user).and_return(@user)
      end

      it "should return true" do
        controller.send(:login_required).should == true
      end
    end

    describe "without logged in user" do
      before :each do
        controller.stub!(:current_user).and_return(nil)
        controller.stub!(:redirect_to)
      end

      it "should redirect to sessions/new" do
        controller.should_receive(:redirect_to).with(new_session_url)
        controller.send(:login_required)
      end

      it "should set the session[:redirect_to] to the requested uri" do
        @request.stub!(:request_uri).and_return(@request_uri)
        controller.send(:login_required)
        session[:redirect_to].should == @request_uri
      end

      it "should not provide a flash notice for now" do
        controller.send(:login_required)
        flash[:notice].should be_blank
      end

      it "should provide a flash notice when we finish beta"
    end
  end

  describe "select organisation" do
    before :each do
      @user = Users.create_user!
      @organisation = @user.organisations.first
      session[:user_id] = @user
    end

    def current_organisation
      controller.send(:current_organisation)
    end

    describe "with an organisation selected" do
      before :each do
        session[:organisation_id] = @organisation.id
      end

      it "should assign the organisation" do
        controller.send(:select_organisation)
        current_organisation.should == @organisation
      end

      it "should not redirect" do
        controller.send(:select_organisation)
        response.should_not be_redirect
      end
    end

    describe "with no organisations" do
      before :each do
        Organisation.delete_all
      end

      it "should redirect to the new organisation page" do
        controller.should_receive(:redirect_to).with(new_organisation_url)
        controller.send(:select_organisation)
      end
    end

    describe "with only one organisation" do
      before :each do
        Organisation.delete_all
        @organisation = Organisations.create_organisation
        @user.organisations << @organisation
        @user.save!
      end

      it "should set the organisation" do
        session[:organisation_id] = nil
        controller.send(:select_organisation)
        current_organisation.should == @organisation
      end

      it "should set the organisation id in the session" do
        controller.send(:select_organisation)
        session[:organisation_id].should == @organisation.id
      end

      it "should not redirect" do
        controller.should_not_receive(:redirect_to)
        controller.send(:select_organisation)
      end
    end

    describe "with many organisations" do
      before :each do
        session[:organisation_id] = nil
        @alternative_organisation = Organisations.create_organisation!
        @alternative_organisation.organisation_members.create!(
          :user => @user
        )
        @controller.instance_variable_set("@current_user", nil)
        controller.stub!(:redirect_to)
      end

      it "should not assign an organisation" do
        controller.send(:select_organisation)
        current_organisation.should be_nil
      end

      it "should store the request_uri" do
        request.stub!(:request_uri).and_return(@request_uri)
        controller.send(:select_organisation)
        session[:redirect_to].should == @request_uri
      end

      it "should redirect to the organisation page" do
        controller.should_receive(:redirect_to).with(organisations_url)
        controller.send(:select_organisation)
      end
    end
  end

  describe "set_current_user_on_resource" do
    before :each do
      login
      @resource = OpenStruct.new(:current_user => 'me')
    end

    it "should set the user on the resource" do
      controller.instance_variable_set("@application", @resource)
      controller.send(:set_current_user_on_resource)
      @resource.current_user.should == @user
    end

    it "should get the resource name from the controller name" do
      controller.stub!(:controller_name).and_return("stories")
      controller.instance_variable_set("@story", @resource)
      controller.send(:set_current_user_on_resource)
      @resource.current_user.should == @user
    end

    it "should cope with the resource not being assigned" do
      lambda { 
        controller.send(:set_current_user_on_resource)
      }.should_not raise_error
    end

    it "should cope with the resource not responding to current_user=" do
      resource = Time.new
      controller.instance_variable_set("@story", resource)
      lambda { 
        controller.send(:set_current_user_on_resource)
      }.should_not raise_error
    end
  end
end
