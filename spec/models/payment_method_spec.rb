require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PaymentMethod do
  before(:each) do
    @valid_attributes = {
      :last_four_digits => 1,
      :expiry_month => 1,
      :expiry_year => 1
    }
  end

  it "should create a new instance given valid attributes" do
    PaymentMethod.create!(@valid_attributes)
  end

  describe "associations" do
    it "should belong to a billing address" do
      PaymentMethod.should belong_to(:billing_address)
    end

    it "should belong to a user" do
      PaymentMethod.should belong_to(:user)
    end

    it "should have one organisation" do
      PaymentMethod.should belong_to(:organisation)
    end
  end

  describe "creation" do
    before :each do
      @payment_method = PaymentMethods.create_payment_method!(
        :card_number => 1111222233334444
      )
      @payment_method.save
    end

    it "should set the last four digits" do
      @payment_method.last_four_digits.should == 4444
    end
  end
end
