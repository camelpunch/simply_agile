require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UserAcknowledgementsController do
  before :each do
    @sponsor = Users.create_user!
    @user = Users.create_user!(
      :sponsor => @sponsor
    )
    @organisation = @sponsor.organisations.first
    @organisation_member =
      @organisation.organisation_members.create!(:user => @user)
  end

  describe "new" do
    def do_call
      get :new, :user_id => @user.id
    end

    it_should_behave_like "it's successful"

    it "should assign the user" do
      do_call
      assigns[:user].should == @user
    end
  end

  describe "create" do
    def do_call(options = {})
      token = options[:token] || @organisation_member.acknowledgement_token
      post :create, :user_id => @user.id,
        :token => token, :password => @password
    end

    before :each do
      @password = 'some password'
      controller.stub!(:get_user)
      controller.instance_variable_set("@user", @user)
    end

    it "should call acknowledge on the user" do
      @user.should_receive(:acknowledge)
      do_call
    end

    it "should pass the token to acknowledge" do
      @user.should_receive(:acknowledge) do |args|
        args.should include(:token => @organisation_member.acknowledgement_token)
      end
      do_call
    end
    
    it "should pass the password to acknowledge" do
      @user.should_receive(:acknowledge) do |args|
        args.should include(:password => @password)
      end
      do_call
    end

    describe "success" do
      before :each do
        @user.stub!(:acknowledge).and_return(true)
      end

      it "should redirect to the home page" do
        do_call
        response.should redirect_to(root_url)
      end

      it "should set the user id" do
        do_call
        session[:user_id].should == @user.id
      end
    end

    describe "failure" do
      before :each do
        @user.stub!(:acknowledge).and_return(false)
      end

      it "should display the form again" do
        do_call
        response.should render_template('user_acknowledgements/new')
      end

      it "should not set the user id" do
        do_call
        session[:user_id].should be_nil
      end
    end
  end

end
