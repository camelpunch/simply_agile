require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Authorisation do
  describe "associations" do
    it "should belong to a payment" do
      Authorisation.should belong_to(:payment)
    end
  end

  describe "creation" do
    before :each do
      @payment_method = PaymentMethods.create_payment_method!
      @credit_card = @payment_method.credit_card
      @amount = 100
    end

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
    end
  end
end
