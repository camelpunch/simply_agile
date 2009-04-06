require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Invoice do
  before(:each) do
    @valid_attributes = {
      :amount => 9.99,
      :vat_rate => 9.99,
      :vat_amount => 9.99,
      :customer_name => "value for customer_name",
      :customer_address_line_1 => "value for customer_address_line_1",
      :customer_address_line_2 => "value for customer_address_line_2",
      :customer_county => "value for customer_county",
      :customer_town => "value for customer_town",
      :customer_postcode => "value for customer_postcode",
      :customer_country => "value for customer_country"
    }
  end

  it "should create a new instance given valid attributes" do
    Invoice.create!(@valid_attributes)
  end

  describe "associations" do
    it "should belong to a payment" do
      Invoice.should belong_to(:payment)
    end
  end

  describe "to_s" do
    describe "new record" do
      it "should return 'New Invoice'" do
        invoice = Invoice.new
        invoice.to_s.should == 'New Invoice'
      end
    end

    describe "existing" do
      it "should add sa- to the id" do
        invoice = Invoice.create!
        invoice.to_s.should == "sa-#{invoice.id}"
      end
    end
  end
end
