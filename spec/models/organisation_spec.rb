require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Organisation do
  before(:each) do
    @valid_attributes = {
      :name => "value for name"
    }
  end

  it "should create a new instance given valid attributes" do
    Organisation.create!(@valid_attributes)
  end

  describe "prompting for payment method" do
    before :each do
      today = Date.today
      period = Organisation::PAYMENT_LOGIN_GRACE_PERIOD

      @no_payment_before_limit = Organisations.
        create_organisation!(:created_at => (period-1).days.ago)

      @no_payment_after_limit = Organisations.
        create_organisation!(:created_at => period.days.ago)

      expired_payment_method = PaymentMethods.
        create_payment_method!(:expiry_year => today.year,
                               :expiry_month => today.month - 1)

      @expired = Organisations.
        create_organisation!(:payment_method => expired_payment_method)

      failed_payment_method = PaymentMethods.
        create_payment_method!(:has_failed => true)

      @failed = Organisations.
        create_organisation!(:payment_method => failed_payment_method)
    end

    it "should not prompt if there is no payment method after PAYMENT_LOGIN_GRACE_PERIOD-1 days" do
      @no_payment_before_limit.should_not have_payment_method_prompt
    end

    it "should prompt if there is no payment method after PAYMENT_LOGIN_GRACE_PERIOD days" do
      @no_payment_after_limit.should have_payment_method_prompt
    end

    it "should prompt if a payment method has expired" do
      @expired.should have_payment_method_prompt
    end

    it "should prompt if a payment method has failed" do
      @failed.should have_payment_method_prompt
    end
  end

  describe "associations" do
    it "should have many projects" do
      Organisation.should have_many(:projects)
    end

    it "should have many stories" do
      Organisation.should have_many(:stories)
    end

    it "should have many iterations" do
      Organisation.should have_many(:iterations)
    end

    it "should have many organisation members" do
      Organisation.should have_many(:organisation_members)
    end

    it "should have many users" do
      Organisation.should have_many(:users)
    end

    it "should have one payment method" do
      Organisation.should have_one(:payment_method)
    end
  end
end
