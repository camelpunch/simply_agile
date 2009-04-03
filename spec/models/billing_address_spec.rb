require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe BillingAddress do
  before(:each) do
    @valid_attributes = {
      :name => "value for name",
      :address_line_1 => "value for address_line_1",
      :address_line_2 => "value for address_line_2",
      :county => "value for county",
      :town => "value for town",
      :postcode => "value for postcode",
      :country => "value for country",
      :telephone_number => "value for phone_number"
    }
  end

  it "should create a new instance given valid attributes" do
    BillingAddress.create!(@valid_attributes)
  end

  describe "validations" do
    before :each do
      @billing_address = BillingAddress.new
      @billing_address.valid?
    end

    it "should require a name" do
      @billing_address.should have(1).error_on(:name)
    end
    
    it "should require an address line 1" do
      @billing_address.should have(1).error_on(:address_line_1)
    end

    it "should require a town" do
      @billing_address.should have(1).error_on(:town)
    end

    it "should require a postcode" do
      @billing_address.should have(1).error_on(:postcode)
    end

    it "should require a country" do
      @billing_address.should have(1).error_on(:country)
    end

    it "should require a telephone number" do
      @billing_address.should have(1).error_on(:telephone_number)
    end
  end
end
