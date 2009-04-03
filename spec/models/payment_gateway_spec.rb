require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class PaymentClass
  include PaymentGateway
  attr_accessor :status
end

describe PaymentGateway do
  before :each do
    @payment_class = PaymentClass.new
    @vendor = "jandaweb"
  end

  describe "vendor" do
    it "should load the vendor from a config file" do
      @payment_class.vendor.should == @vendor
    end
  end

  describe "gateway" do
    def do_protx_action
      @payment_class.gateway
    end

    it_should_behave_like "it uses protx"

    it "should return the gateway object" do
      @payment_class.gateway.should == @gateway
    end
  end

  describe "successful" do
    it "should be true if status is OK" do
      @payment_class.status = 'OK'
      @payment_class.should be_successful
    end

    it "should be false otherwise" do
      @payment_class.status = 'DECLINED'
      @payment_class.should_not be_successful
    end
  end
end