require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UserVerificationsController do
  before :each do
    @user = Users.create_user!
  end

  describe "new" do
    def do_call
      get :new, :user_id => @user.id
    end

    it_should_behave_like "it's successful"
  end

  describe "GET create" do
    def do_call(options = {})
      token = options[:token] || @user.verification_token
      get :create, :user_id => @user.id, :token => token
    end

    describe "if the user and token match" do
      it "should redirect to the home page" do
        do_call
        response.should redirect_to(root_url)
      end

      it "should verify the user" do
        do_call
        @user.reload
        @user.verified?.should be_true
      end

      it "should log the user in" do
        do_call
        session[:user_id].should == @user.id
      end
    end

    describe "if the token does not match" do
      it "should display the new page" do
        do_call(:token => '12345')
        response.should render_template('user_verifications/new')
      end

      it "should not set verified to true" do
        do_call(:token => '12345')
        @user.reload
        @user.verified.should be_false
      end

      it "should not log the user in" do
        do_call(:token => '12345')
        session[:user_id].should be_nil
      end
    end

    describe "if the user id does not match" do
      it "should display the new page" do
        do_call(:user_id => '123')
        # #response.header
      end
    end
  end
end
