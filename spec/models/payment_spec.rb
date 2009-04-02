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
end
