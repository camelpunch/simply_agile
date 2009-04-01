require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe OrganisationsController do
  before :each do
    login
    session[:organisation_id] = nil

    @payment_plan = PaymentPlans.create_payment_plan!
  end

  describe "new" do
    def do_call
      get :new
    end

    it "should instantiate a new organisation" do
      do_call
      assigns[:organisation].should be_an(Organisation)
    end

    it "should instantiate plans" do
      do_call
      assigns[:payment_plans].first.should be_a(PaymentPlan)
    end

    it_should_behave_like "it sets @current_organisation"
  end

  describe "create" do
    def do_call(params = {})
      post :create, :organisation => {
        :name => 'New name',
        :payment_plan_id => @payment_plan.id.to_s
      }.merge(params)
    end

    it_should_behave_like "it sets @current_organisation"

    describe "success" do
      it "should switch to the new organisation" do
        do_call
        organisation = Organisation.last(:order => 'id')
        session[:organisation_id].should == organisation.id
      end

      it "should redirect to the home url" do
        do_call
        response.should redirect_to(home_url)
      end

      it "should create a new organisation" do
        lambda {do_call}.should change(Organisation, :count).by(1)
      end

      it "should assign the organisation to the user" do
        do_call
        Organisation.last(:order => 'id').users.should == [@user]
      end
    end

    describe "failure" do
      it "should re-render the new page" do
        do_call :name => ''
        response.should render_template('organisations/new')
      end

      it "should not create an organisation" do
        lambda {do_call(:name => '')}.should_not change(Organisation, :count)
      end

      it "should assign payment plans" do
        do_call :name => ''
        assigns[:payment_plans].first.should be_a(PaymentPlan)
      end
    end
  end

  describe "index" do
    def do_call
      get :index
    end

    it "should assign the user's organisations" do
      do_call
      assigns[:organisations].should == @user.organisations
    end

    it_should_behave_like "it sets @current_organisation"
  end
end
