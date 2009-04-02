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
end
