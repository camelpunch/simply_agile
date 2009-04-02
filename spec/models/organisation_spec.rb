require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Organisation do
  before(:each) do
    @valid_attributes = {
      :name => "value for name",
      :payment_plan_id => PaymentPlans.create_payment_plan!.id
    }
  end

  it "should create a new instance given valid attributes" do
    Organisation.create!(@valid_attributes)
  end

  describe "prompting for payment method" do
    before :each do
      today = Date.today
      period = Organisation::PAYMENT_LOGIN_GRACE_PERIOD

      @no_payment_before_limit = Organisations.create_organisation!
      @no_payment_before_limit.created_at = (period-1).days.ago

      @no_payment_after_limit = Organisations.create_organisation!
      @no_payment_after_limit.created_at = (period+1).days.ago

      expired_payment_method = mock_model(PaymentMethod, :has_expired? => true)
      @expired = Organisations.create_organisation!
      @expired.stub!(:payment_method).and_return(expired_payment_method)

      failed_payment_method = mock_model(PaymentMethod, 
                                         :has_expired? => false,
                                         :has_failed? => true)
      @failed = Organisations.create_organisation!
      @failed.stub!(:payment_method).and_return(failed_payment_method)
    end

    it "should not prompt if there is no payment method before PAYMENT_LOGIN_GRACE_PERIOD days" do
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

  describe "active" do
    before :each do
      @active = Organisations.create_organisation!
      @suspended = Organisations.create_organisation!
      @suspended.update_attribute :suspended, true
    end

    it "should not get suspended organisations" do
      Organisation.active.should_not include(@suspended)
    end

    it "should get not-suspended organisations" do
      Organisation.active.should include(@active)
    end
  end

  describe "default scope" do
    before :each do
      Organisation.delete_all
      @b = Organisations.create_organisation! :name => 'b'
      @a = Organisations.create_organisation! :name => 'a'
    end

    it "should order by name" do
      Organisation.all.should == [@a, @b]
    end
  end

  describe "protection" do
    before :each do
      @user = mock_model User, :valid? => true
    end

    it "should not allow mass-assignment of user ids" do
      organisation = Organisation.create! @valid_attributes.merge(:user_ids => [@user.id])
      organisation.users.should be_empty
    end

    it "should allow mass-assignment of users" do
      organisation = Organisation.new @valid_attributes.merge(:users => [@user])
      organisation.users.should == [@user]
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

    it "should have many members" do
      Organisation.should have_many(:members)
    end

    it "should have many users" do
      Organisation.should have_many(:users)
    end

    it "should have one payment method" do
      Organisation.should have_one(:payment_method)
    end

    it "should belong to a payment plan" do
      Organisation.should belong_to(:payment_plan)
    end
  end

  describe "validations" do
    before :each do
      @organisation = Organisation.new
      @organisation.valid?
    end

    it "should require a name" do
      @organisation.should have(1).error_on(:name)
    end

    it "should require a payment plan" do
      @organisation.should have(1).error_on(:payment_plan_id)
    end

    it "should require that the organisation is not suspended" do
      @organisation.suspended = true
      @organisation.valid?
      @organisation.should have(1).error_on(:suspended)
    end
  end
end
