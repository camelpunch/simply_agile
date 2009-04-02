require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class PaymentClass
  include PaymentGateway
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
end