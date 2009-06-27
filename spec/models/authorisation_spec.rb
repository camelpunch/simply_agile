require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Authorisation do
  before :each do
    stub_payment_gateway
    @payment_method = PaymentMethods.create_payment_method!
    @credit_card = @payment_method.credit_card
    @amount = 100
  end

  describe "associations" do
    it "should belong to a payment" do
      Authorisation.should belong_to(:payment)
    end
  end

  describe "creation" do
    def do_protx_action
      @authorisation = Authorisation.create!(
        :amount => @amount,
        :payment_method => @payment_method
      )
    end

    it_should_behave_like "it uses protx"

    it "should create a new payment" do
      payment_count = Payment.count
      do_protx_action
      Payment.count.should == payment_count + 1
    end

    it "should associated with the payment" do
      do_protx_action
      @authorisation.payment.should be_kind_of(Payment)
    end

    describe "authorize on the gateway" do
      it "should be called" do
        @gateway.should_receive(:authorize)
        do_protx_action
      end

      it "should pass in the amount" do
        @gateway.should_receive(:authorize) do |amount, card|
          amount.should == @amount
        end
        do_protx_action
      end

      it "should pass in the credit card" do
        @gateway.should_receive(:authorize) do |amount, card|
          card.number.should == @credit_card.number
        end
        do_protx_action
      end

      it "should pass in an order id" do
        @gateway.should_receive(:authorize) do |amount, card, args|
          args[:order_id].should_not be_nil
        end
        do_protx_action
      end

      it "should set authorization type to authenticate" do
        @gateway.should_receive(:authorize) do |amount, card, args|
          args[:authenticate].should be_true
        end
        do_protx_action
      end

      it "should store the status" do
        do_protx_action
        @authorisation.status.should == "OK"
      end

      it "should store the status_detail" do
        do_protx_action
        @authorisation.status_detail.should ==
          "VSP Direct transaction from VSP Simulator."
      end
    end

    describe "successful authorization" do
      it "should set the vpstxid in the payment" do
        do_protx_action
        @authorisation.payment.vpstxid.should ==
          "{F48981C8-158B-4EFA-B8A8-635D3B7A86CE}"
      end

      it "should set the security key in the payment" do
        do_protx_action
        @authorisation.payment.security_key.should == "08S2ZURVM4"
      end

      it "should set the txauthno in the payment" do
        do_protx_action
        @authorisation.payment.tx_auth_no.should == "5123"
      end

      it "should store the authorization" do
        do_protx_action
        @authorisation.authorisation.should ==
          "2;{F48981C8-158B-4EFA-B8A8-635D3B7A86CE};5123;08S2ZURVM4"
      end
    end
  end

  describe "capture" do
    before :each do
      @authorisation = Authorisation.create!(
        :amount => @amount,
        :payment_method => @payment_method
      )

      stub_payment_gateway
    end

    it "should create a new capture object" do
      capture_count = Capture.count
      @authorisation.capture(@amount)
      Capture.count.should == capture_count + 1
    end

    it "should associate the capture with the payment" do
      @authorisation.capture(@amount)
      @authorisation.payment.capture.should be_kind_of(Capture)
    end
  end

  describe "void" do
    before :each do
      @authorisation = Authorisation.create!(
        :amount => @amount,
        :payment_method => @payment_method
      )

      stub_payment_gateway
    end

    it "should create a new void object" do
      void_count = Void.count
      @authorisation.void
      Void.count.should == void_count + 1
    end

    it "should association the void with the payment" do
      @authorisation.void
      @authorisation.payment.void.should be_kind_of(Void)
    end
  end
end
