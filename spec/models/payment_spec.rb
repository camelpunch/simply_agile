require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Payment do
  before(:each) do
    @valid_attributes = {
      :organisation_id => 1,
      :vpstxid => "value for vpstxid",
      :security_key => "value for security_key",
      :vendor_tx_code => "value for vendor_tx_code"
    }
  end

  it "should create a new instance given valid attributes" do
    Payment.create!(@valid_attributes)
  end

  describe "associations" do
    it "should have_one authorisation" do
      Payment.should have_one(:authorisation)
    end

    it "should have_one capture" do
      Payment.should have_one(:capture)
    end

    it "should have_one void" do
      Payment.should have_one(:void)
    end

    it "should have one invoice" do
      Payment.should have_one(:invoice)
    end
    
    it "should belong to an organisation" do
      Payment.should belong_to(:organisation)
    end
  end

  describe "vendor_tx_code" do
    before :each do
      @id = "some id"
      ActiveMerchant::Utils.should_receive(:generate_unique_id).and_return(@id)
      @payment = Payment.create!
    end

    it "should use generate_unique_id from ActiveMerchant" do
      @payment.vendor_tx_code.should == @id
    end
  end

  describe "reference" do
    before :each do
      @vpstxid = "{F48981C8-158B-4EFA-B8A8-635D3B7A86CE}"
      @tx_auth_no = "5123"
      @security_key = "08S2ZURVM4"
      @payment = Payment.create!(
        :vpstxid => @vpstxid,
        :tx_auth_no => @tx_auth_no,
        :security_key => @security_key
      )
    end

    it "should join the vendor id, vps tx id, auth id and security key" do
      @payment.reference.should ==
        "#{@payment.vendor_tx_code};#{@vpstxid};#{@tx_auth_no};#{@security_key}"
    end
  end

  describe "capture_or_repeat" do
    before :each do
      @vpstxid = "{F48981C8-158B-4EFA-B8A8-635D3B7A86CE}"
      @tx_auth_no = "5123"
      @security_key = "08S2ZURVM4"
      @organisation = Organisations.create_organisation!
      @payment = Payment.create!(
        :vpstxid => @vpstxid,
        :tx_auth_no => @tx_auth_no,
        :security_key => @security_key,
        :organisation => @organisation
      )

      stub_payment_gateway
    end

    describe "with no previous capture" do
      it "should capture the previous authentication" do
        lambda {
          @payment.capture_or_repeat({})
        }.should change(Capture, :count).by(1)
      end

      it "should not create a new repeat payment" do
        lambda {
          @payment.capture_or_repeat({})
        }.should_not change(Repeat, :count)
      end

      it "should associate the capture with the payment" do
        @payment.capture_or_repeat({})
        capture = Capture.last
        capture.payment.should == @payment
      end

      it "should pass through the amount" do
        amount = 100
        @payment.capture_or_repeat(:amount => amount)
        capture = Capture.last
        capture.amount.should == amount
      end

      it "should strip out description" do
        lambda {
          @payment.capture_or_repeat(:description => 'some description')
        }.should_not raise_error(ActiveRecord::UnknownAttributeError)
      end
    end

    describe "with a previous capture" do
      before :each do
        Capture.create!(:payment => @payment)
      end

      it "should create a new repeat payment" do
        lambda {
          @payment.capture_or_repeat({})
        }.should change(Repeat, :count).by(1)
      end

      it "should not capture the previous authentication" do
        lambda {
          @payment.capture_or_repeat({})
        }.should_not change(Capture, :count)
      end

      it "should pass through the amount" do
        amount = 100
        @payment.capture_or_repeat(:amount => amount)
        repeat = Repeat.last
        repeat.amount.should == amount
      end

      it "should pass through the amount description" do
        description = "some awesome product"
        @payment.capture_or_repeat(:description => description)
        repeat = Repeat.last
        repeat.description.should == description
      end

      it "should pass in the payment's organisation" do
        @payment.capture_or_repeat({})
        repeat = Repeat.last
        repeat.payment.organisation.should == @organisation
      end

      it "should pass in the payment's reference" do
        @payment.reference.should_not be_nil
        repeat = Repeat.new
        Repeat.should_receive(:new).with do |params|
          params[:authorization].should == @payment.reference
        end.and_return(repeat)
        @payment.capture_or_repeat({})
      end
    end
  end
end
