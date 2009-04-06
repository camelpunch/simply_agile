require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe RepeatObserver do
  before :each do
    @user = mock_model User
    @billing_address = mock_model(BillingAddress,
                                  :name => 'Billing Name',
                                  :address_line_1 => 'asdf',
                                  :address_line_2 => 'fdas',
                                  :county => 'county',
                                  :town => 'town',
                                  :postcode => 'se22 8gb',
                                  :country => 'country')
    @payment_method = mock_model(PaymentMethod,
                                 :billing_address => @billing_address,
                                 :last_four_digits => 234,
                                 :user => @user)
    @payment_plan = mock_model PaymentPlan, :name => 'plan', :price => 39.28
    @organisation = mock_model(Organisation,
                               :name => 'asdf',
                               :next_payment_date => 2.days.ago.to_date,
                               :payment_plan => @payment_plan,
                               :payment_method => @payment_method)
    @payment = mock_model Payment, :organisation => @organisation
    @repeat = mock_model(Repeat, 
                         :payment => @payment,
                         :amount => 3001) # pence
    @observer = RepeatObserver.instance
  end

  describe "after_create" do
    def do_call
      @observer.after_create(@repeat)
    end

    describe "when successful" do
      before :each do
        @repeat.stub!(:successful?).and_return(true)
      end

      it "should create an invoice" do
        lambda {do_call}.should change(Invoice, :count).by(1)
      end

      it "should set the last four digits" do
        Invoice.should_receive(:create!).
          with hash_including(:last_four_digits => @payment_method.last_four_digits)
        do_call
      end

      it "should set the payment" do
        Invoice.should_receive(:create!).
          with hash_including(:payment => @payment)
        do_call
      end

      it "should set the user" do
        Invoice.should_receive(:create!).
          with hash_including(:user => @user)
        do_call
      end

      it "should set the organisation name" do
        Invoice.should_receive(:create!).
          with hash_including(:organisation_name => @organisation.name)
        do_call
      end

      it "should set the payment plan name" do
        Invoice.should_receive(:create!).
          with hash_including(:payment_plan_name => @payment_plan.name)
        do_call
      end

      it "should set the payment plan price" do
        Invoice.should_receive(:create!).
          with hash_including(:payment_plan_price => @payment_plan.price)
        do_call
      end

      it "should set the date from the organisation next payment date" do
        Invoice.should_receive(:create!).
          with hash_including(:date => @organisation.next_payment_date)
        do_call
      end

      it "should copy the address details from the organisation" do
        expected_address_details = {
          :customer_name => @billing_address.name,
          :customer_address_line_1 => @billing_address.address_line_1,
          :customer_address_line_2 => @billing_address.address_line_2,
          :customer_county => @billing_address.county,
          :customer_town => @billing_address.town,
          :customer_postcode => @billing_address.postcode,
          :customer_country => @billing_address.country,
        }

        Invoice.should_receive(:create!).
          with hash_including(expected_address_details)

        do_call
      end

      it "should copy the amount from the payment plan price" do
        Invoice.should_receive(:create!).
          with hash_including(:amount => 39.28)
        do_call
      end
    end

    describe "when unsuccessful" do
      before :each do
        @repeat.stub!(:successful?).and_return(false)
      end

      it "should not create an invoice" do
        lambda {do_call}.should_not change(Invoice, :count)
      end

      it "should return true" do
        do_call.should be_true
      end
    end
  end

end
