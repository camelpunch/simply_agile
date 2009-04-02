require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PaymentMethodsController do
  before :each do
    login
    @user.payment_methods << PaymentMethods.create_payment_method!
    @payment_method = @user.payment_methods.first
  end

  describe "index" do
    def do_call
      get :index
    end

    it_should_behave_like "it's successful"

    describe "with payment methods" do
      it "should render the index" do
        do_call
        response.should render_template('payment_methods/index')
      end

      it "should assign payment methods" do
        do_call
        assigns[:payment_methods].first.should be_a(PaymentMethod)
      end
    end

    describe "without payment methods" do
      before :each do
        PaymentMethod.delete_all
      end
      
      it "should render the index guidance" do
        do_call
        response.should render_template('payment_methods/index_guidance')
      end
    end
  end

  describe "destroy" do
    def do_call
      delete :destroy, :id => @payment_method.id
    end

    it "should delete the payment method" do
      do_call
      lambda {@payment_method.reload}.
        should raise_error(ActiveRecord::RecordNotFound)
    end

    it "should redirect to the index" do
      do_call
      response.should redirect_to(payment_methods_url)
    end

    it "should provide a flash notice" do
      do_call
      flash[:notice].should_not be_blank
    end
  end
  
  describe "GET 'new'" do
    def do_call
      get :new, :organisation_id => @organisation
    end

    before :each do
      @organisation = Organisations.create_organisation!
    end

    it_should_behave_like "it's successful"

    describe "payment method" do
      it "should be assigned" do
        do_call
        assigns[:payment_method].should be_kind_of(PaymentMethod)
      end
      
      it "should belong to the organisation" do
        do_call
        assigns[:payment_method].organisation.should == @organisation
      end
    end
  end

  describe "post create" do
    def do_call
      post :create, :organisation_id => @organisation,
        :payment_method => @payment_method_params
    end

    before :each do
      @payment_method_params = {
        :cardholder_name => 'Mr Cardholder',
        :card_number => '4444333322221111',
        :expiry_month => '01',
        :expiry_year => '99',
        :cv2 => '123',
        :billing_address_attributes => {
          :address_line_1 => '1 Some Street',
          :town => 'Sometown',
          :postcode => 'AA1 1AA',
          :country => 'United Kingdom',
          :telephone_number => '07777111111'
        }
      }
    end

    describe "with valid data" do

      it "should create a new payment_method for the organisation" do
        do_call
        @organisation.payment_method.should_not be_nil
      end

      it "should set the card details" do
        do_call
        @organisation.payment_method.last_four_digits.should_not be_nil
        @organisation.payment_method.expiry_month.should ==
          @payment_method_params[:expiry_month].to_i
        @organisation.payment_method.expiry_year.should ==
          @payment_method_params[:expiry_year].to_i
      end

      it "should set the billing address" do
        do_call
        @organisation.payment_method.billing_address.should_not be_nil
      end

      it "should redirect to page showing the payment for that organisation" do
        do_call
        response.should be_redirect
      end
    end
  end
end
