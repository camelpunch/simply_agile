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

  describe "vendor_tx_code" do
    before :each do
      @payment = Payment.create!
    end

    it "should be set to the current year followed by the number of payments" do
      @payment.vendor_tx_code.should == "#{Date.today.year}-#{Payment.count}"
    end
  end
end
