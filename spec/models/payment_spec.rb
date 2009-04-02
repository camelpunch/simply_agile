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
end
