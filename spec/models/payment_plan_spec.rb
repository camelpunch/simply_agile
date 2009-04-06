require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PaymentPlan do
  before(:each) do
    @valid_attributes = {
      :name => "value for name",
      :description => "value for description",
      :price => 9.99
    }
  end

  it "should create a new instance given valid attributes" do
    PaymentPlan.create!(@valid_attributes)
  end

  describe "default scope" do
    before :each do
      PaymentPlan.delete_all
      @two_pounds = PaymentPlans.create_payment_plan! :name => 'A', :price => 2
      @one_pound = PaymentPlans.create_payment_plan! :name => 'Z', :price => 1
    end

    it "should order by price ascending" do
      PaymentPlan.all.should == [@one_pound, @two_pounds]
    end
  end

  describe "total" do
    before :each do
      @payment_plan = PaymentPlans.create_payment_plan!
    end

    it "should return the price + the VAT amount" do
      @payment_plan.total.to_s.should == (@payment_plan.price +
        (@payment_plan.price / 100 * Invoice::VAT_RATE)).to_s
    end
  end
end
