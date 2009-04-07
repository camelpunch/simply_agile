require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UsersController do
  describe "instance variable setup" do
    describe "new user" do
      it "should call create on User" do
        User.should_receive(:new)
        controller.send(:new_user)
      end

      it "should assign the instance" do
        user = mock_model(User)
        User.stub!(:new).and_return(user)
        controller.send(:new_user)
        controller.instance_variable_get("@user").should == user
      end
    end
  end

  describe "index" do
    it "should redirect to the home url" do
      login
      get :index
      response.should redirect_to(home_url)
    end
  end

  describe "show" do
    def do_call
      get :show, :id => @user.id
    end

    before :each do
      login
    end

    it_should_behave_like "it's successful"

    it "should disallow getting of other user pages" do
      get :show, :id => Users.create_user!.id      
      response.should redirect_to(user_url(@user))
    end

    it_should_behave_like "it sets @current_organisation"
  end

  describe "new" do
    def do_call
      get :new
    end

    it_should_behave_like "it's successful"

    it "should assign a new user" do
      controller.should_receive(:new_user)
      do_call
    end
  end

  describe "create" do
    def do_call
      post :create, :user => @user_params
    end

    before :each do
      @user = User.new
      controller.stub!(:new_user)
      controller.instance_variable_set("@user", @user)

      @user_params = {
        "email_address" => 'user@jandaweb.com',
        "password" => 'password'
      }
    end

    it "should assign a new user" do
      controller.should_receive(:new_user)
      do_call
    end

    it "should update user params and signup" do
      @user.should_receive(:attributes=).with(@user_params.merge('signup' => true))
      do_call
    end

    it "should try to save the user object" do
      @user.should_receive(:save)
      do_call
    end

    it "should provide a flash notice" do
      do_call
      flash[:notice].should_not be_blank
    end

    describe "valid user details" do
      before(:each) do
        @user.stub!(:save).and_return(true)
      end

      it "should redirect to the home page" do
        do_call
        response.should redirect_to(home_url)
      end

      it "should set the user id in the session" do
        do_call
        session[:user_id].should == @user.id
      end
    end

    describe "invalid user details" do
      before(:each) do
        @user.stub!(:save).and_return(false)
      end

      it "should display the new template" do
        do_call
        response.should render_template('users/new')
      end

      it "should not set the user id in the session" do
        do_call
        session[:user_id].should be_nil
      end
    end
  end
end
