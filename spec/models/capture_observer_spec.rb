require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CaptureObserver do
  before :each do
    @billing_address = mock_model(BillingAddress,
                                  :name => 'Billing Name',
                                  :address_line_1 => 'asdf',
                                  :address_line_2 => 'fdas',
                                  :county => 'county',
                                  :town => 'town',
                                  :postcode => 'se22 8gb',
                                  :country => 'country')
    @payment_method = mock_model(PaymentMethod,
                                 :billing_address => @billing_address)
    @organisation = mock_model(Organisation,
                               :payment_method => @payment_method)
    @payment = mock_model Payment, :organisation => @organisation
    @capture = mock_model(Capture, 
                          :payment => @payment,
                          :amount => 3001) # pence
    @observer = CaptureObserver.instance
  end

  describe "after_create" do
    describe "when successful" do
      before :each do
        @capture.stub!(:successful?).and_return(true)
      end

      it "should create an invoice" do
        lambda {@observer.after_create(@capture)}.
          should change(Invoice, :count).by(1)
      end

      it "should set the payment" do
        Invoice.should_receive(:create!).
          with hash_including(:payment => @payment)
        @observer.after_create(@capture)
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

        @observer.after_create(@capture)
      end

      it "should copy the amount from the capture" do
        Invoice.should_receive(:create!).
          with hash_including(:amount => 30.01)
        @observer.after_create(@capture)
      end
    end

    describe "when unsuccessful" do
      before :each do
        @capture.stub!(:successful?).and_return(false)
      end

      it "should not create an invoice" do
        lambda {@observer.after_create(@capture)}.
          should_not change(Invoice, :count)
      end

      it "should return true" do
        @observer.after_create(@capture).should be_true
      end
    end
  end

end
