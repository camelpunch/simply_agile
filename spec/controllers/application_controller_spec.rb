require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ApplicationController do
  
  before :each do
    @user = mock_model User
    @referer = 'some/referer'
#    @request = mock('Request',
#      :protocol => '',
#      :host_with_port => '',
#      :referer => @referer)
#    controller.stub!(:request).and_return(@request)
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

  describe "get_project" do
    before :each do
      login
      stub_projects!
    end

    it "should restrict to user's projects" do
      controller.stub!(:params).and_return({:project_id => @project.id.to_s})
      @projects.stub!(:find).with(@project.id.to_s).and_return(@project)
      controller.send(:get_project)
      controller.instance_variable_get("@project").should == @project
    end

    it "should not find if there's no params[:project_id]" do
      controller.stub!(:params).and_return({})
      @user.should_not_receive(:organisation)
      controller.send(:get_project)
    end
  end

  describe "get_organisation" do
    before :each do
      login
    end
    
    it "should get the organisation the current user" do
      @user.should_receive(:organisation)
      controller.send(:get_organisation)
    end

    it "should assign the instance variable" do
      controller.send(:get_organisation)
      controller.instance_variable_get("@organisation").should == @organisation
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

      it "should set the session[:redirect_to] to the referer" do
        @request.stub!(:referer).and_return(@referer)
        controller.send(:login_required)
        session[:redirect_to].should == @referer
      end

      it "should provide a flash notice" do
        controller.send(:login_required)
        flash[:notice].should_not be_blank
      end
    end
  end

end
