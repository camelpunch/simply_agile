require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Repeat do
  describe "associations" do
    it "should belong to a payment" do
      Repeat.should belong_to(:payment)
    end
  end

  describe "creation" do
    def do_protx_action
      @authorization = '2;{F48981C8-158B-4EFA-B8A8-635D3B7A86CE};5123;08S2ZURVM4'
      @amount = 100
      @description = "Payment description"
      @repeat = Repeat.create!(
        :authorization => @authorization,
        :amount => @amount,
        :description => @description
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
      @repeat.payment.should be_kind_of(Payment)
    end

    describe "purchase called on the gateway" do
      it "should be called" do
        @gateway.should_receive(:purchase)
        do_protx_action
      end

      it "should pass in the authorization" do
        @gateway.should_receive(:purchase) do |amount, authorization|
          authorization.should == @authorization
        end
        do_protx_action
      end

      it "should pass in the amount" do
        @gateway.should_receive(:purchase) do |amount, authorization|
          amount.should == @amount
        end
        do_protx_action
      end

      it "should pass in the order id" do
        @gateway.should_receive(:purchase) do |amount, authorization, options|
          options[:order_id].should_not be_nil
        end
        do_protx_action
      end

      it "should pass in the description" do
        @gateway.should_receive(:purchase) do |amount, authorization, options|
          options[:description].should == @description
        end
        do_protx_action
      end

      it "should store the status" do
        do_protx_action
        @repeat.status.should == "OK"
      end

      it "should store the status_detail" do
        do_protx_action
        @repeat.status_detail.should == "The transaction was REPEATed successfully."
      end
    end
  end
end
