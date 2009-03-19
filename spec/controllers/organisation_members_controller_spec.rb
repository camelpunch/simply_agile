require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe OrganisationMembersController do
  before :each do
    login
    controller.instance_variable_set("@organisation", @organisation)
  end

  describe "new user" do
    it "should call User.new with the organisation and sponsor" do
      controller.instance_variable_set("@current_user", @user)
      User.should_receive(:new).with(
        :organisation => @organisation,
        :sponsor => @user
      )
      controller.send(:new_user)
    end

    it "should assign the instance variable" do
      User.stub!(:new).and_return(@user)
      controller.send(:new_user)
      controller.instance_variable_get("@user").should == @user
    end
  end

  describe "get user" do
    before :each do
      @users = mock('Users')
      @organisation.stub!(:users).and_return(@users)
    end

    it "should call find on the organisation's users" do
      user_id = "123"
      controller.stub!(:params).and_return(:id => user_id)

      @users.should_receive(:find).with(user_id)
      controller.send(:get_user)
    end

    it "should assign the instance variable" do
      @users.stub!(:find).and_return(@user)
      controller.send(:get_user)
      controller.instance_variable_get("@user").should == @user
    end
  end

  describe "create" do
    def do_call
      post :create, :user => @user_params
    end

    before :each do
      @new_user = User.new
      controller.instance_variable_set("@user", @new_user)
      controller.stub!(:new_user)

      @user_params = { "email_address" => 'user@jandaweb.com' }
    end

    it "should assign the organisation" do
      controller.should_receive(:get_organisation)
      do_call
    end
    
    it "should create a new user" do
      controller.should_receive(:new_user)
      do_call
    end

    it "should assign the user attributes" do
      @new_user.should_receive(:attributes=).with(@user_params)
      do_call
    end

    describe "success" do
      before :each do
        @new_user.stub!(:save).and_return(true)
      end

      it "should redirect to the organisation page" do
        do_call
        response.should redirect_to(organisation_url)
      end
    end

    describe "failure" do
      before :each do
        @new_user.stub!(:save).and_return(false)
      end

      it "should render the organisation page" do
        do_call
        response.should render_template("organisations/show")
      end
    end
  end

  describe "destroy" do
    def do_call
      delete :destroy, :id => @new_user.id
    end

    before :each do
      @new_user = Users.create_user!
      controller.instance_variable_set("@user", @new_user)
      controller.stub!(:get_user)
    end

    it "should assign the user" do
      controller.should_receive(:get_user)
      do_call
    end

    it "should call destroy on the user" do
      @new_user.should_receive(:destroy)
      do_call
    end

    it "should redirect to the organisation page" do
      do_call
      response.should redirect_to(organisation_url)
    end
  end
end
