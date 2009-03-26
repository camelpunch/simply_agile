require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SessionsController do
  it "should not have the login_required filter" do
    SessionsController.filter_chain.should_not include(:login_required)
  end

  describe "new" do
    def do_call
      get :new
    end

    it_should_behave_like "it's successful"
  end

  describe "create" do
    def do_post
      post :create, :user => {
        'email_address' => @user.email_address,
        'password' => @password
      }
    end

    before :each do
      @password = 'asdffasdfsrttr'
      @user = mock_model(User,
                         :email_address => 'me@place.net',
                         :encrypted_password => 'asdf')
    end

    describe "when user is found" do
      before :each do
        User.stub!(:find_by_email_address_and_password).and_return(@user)
      end

      it "should set session[:user_id]" do
        do_post
        session[:user_id].should == @user.id
      end

      describe "and session[:redirect_to] is set" do
        before :each do
          session[:redirect_to] = 'http://test.host/some/place'
          do_post
        end

        it "should redirect to session[:redirect_to]" do
          response.should redirect_to('http://test.host/some/place')
        end

        it "should clear session[:redirect_to]" do
          session[:redirect_to].should be_blank
        end
      end

      describe "and session[:redirect_to] is not set" do
        before :each do
          session[:redirect_to] = nil
          do_post
        end

        it "should redirect to root URL" do
          response.should redirect_to(root_url)
        end
      end
    end

    describe "when user is not found" do
      before :each do
        User.stub!(:find_by_email_address_and_password).and_return(nil)
        do_post
      end

      it "should re-render sessions/new" do
        response.should render_template('sessions/new')
      end

      it "should provide a flash notice" do
        flash = mock('Flash', :now => {})
        controller.stub!(:flash).and_return(flash)
        do_post
        flash.now[:notice].should_not be_blank
      end
    end
  end

  describe "update" do
    def do_call
      put :update, :organisation_id => @organisation.id
    end

    before :each do
      @organisation = Organisations.create_organisation!
    end

    it "should set the organisation_id in the session" do
      do_call
      session[:organisation_id].should == @organisation.id.to_s
    end

    describe "with redirect_to set" do
      before :each do
        @redirect_to = 'http://some.where/'
        session[:redirect_to] = @redirect_to
      end

      it "should redirect to session[:redirect_to]" do
        do_call
        response.should redirect_to(@redirect_to)
      end

      it "should clear session[:redirect_to]" do
        do_call
        session[:redirect_to].should be_nil
      end
    end

    describe "without redirect_to set" do
      it "should redirect to the applicaiton home page" do
        do_call
        response.should redirect_to(root_url)
      end
    end
  end

  describe "destroy" do
    it "should set session user id to nil" do
      session[:user_id] = 1
      delete :destroy
      session[:user_id].should be_nil
    end

    it "should set organisation id to nil" do
      session[:organisation_id] = 1
      delete :destroy
      session[:organisation_id].should be_nil
    end

    it "should redirect to /" do
      delete :destroy
      response.should redirect_to(root_url)
    end
  end
end
