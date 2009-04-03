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

      @no_next_payment_date = Organisations.create_organisation!
      @no_next_payment_date.created_at = (period+1).days.ago

      Organisation.with_observers(:organisation_observer) do
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
    end

    it "should not prompt if there is no next_payment_date but is after period" do
      @no_next_payment_date.should have_valid_payment_method
    end

    it "should not prompt if there is no payment method before PAYMENT_LOGIN_GRACE_PERIOD days" do
      @no_payment_before_limit.should have_valid_payment_method
    end

    it "should prompt if there is no payment method after PAYMENT_LOGIN_GRACE_PERIOD days" do
      @no_payment_after_limit.should_not have_valid_payment_method
    end

    it "should prompt if a payment method has expired" do
      @expired.should_not have_valid_payment_method
    end

    it "should prompt if a payment method has failed" do
      @failed.should_not have_valid_payment_method
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
      @suspended = Organisations.create_organisation! :name => 'aa'
      @suspended.update_attribute :suspended, true
    end

    it "should order by suspended DESC then name" do
      Organisation.all.should == [@a, @b, @suspended]
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

  describe "payment" do
    before :each do
      stub_payment_gateway
      @organisation = Organisations.create_organisation!
      @organisation.update_attribute(:next_payment_date, Date.today)
      @payment_plan = @organisation.payment_plan

      @payment_method = PaymentMethod.create!(
        :organisation => @organisation,
        :number => '4242424242424242',
        :card_type => 'visa',
        :verification_value => '123',
        :cardholder_name => 'Joe Bloggs',
        :month => Date.today.month,
        :year => Date.today.year + 1,
        :repeat_payment_token => @token
      )
    end

    it "should create a new repeat payment" do
      repeat = Repeat.new
      Repeat.should_receive(:new).and_return(repeat)
      @organisation.take_payment
    end

    it "should pass the repeat payment token to the Repeat payment" do
      repeat = Repeat.new
      Repeat.should_receive(:new).with do |params|
        params[:authorization].should == @payment_method.repeat_payment_token
      end.and_return(repeat)
      @organisation.take_payment
    end

    it "should pass in the amount from the plan" do
      repeat = Repeat.new
      Repeat.should_receive(:new).with do |params|
        params[:amount].should == @payment_plan.price.to_i * 100
      end.and_return(repeat)
      @organisation.take_payment
    end

    it "should pass in a description" do
      repeat = Repeat.new
      Repeat.should_receive(:new).with do |params|
        params[:description].should == @organisation.name
      end.and_return(repeat)
      @organisation.take_payment
    end

    it "should set the next payment date to next month" do
      payment_date = @organisation.next_payment_date
      @organisation.take_payment
      @organisation.reload
      @organisation.next_payment_date.should == payment_date >> 1
    end

    describe "with next payment date in the future" do
      before :each do
        @organisation.next_payment_date = Date.tomorrow
      end

      it "should raise an exception" do
        lambda {
          @organisation.take_payment
        }.should raise_error(PaymentNotDueException)
      end

      it "should not try to take any money" do
        Repeat.should_not_receive(:new)
      end
    end

    describe "with no payment date" do
      before :each do
        @organisation.next_payment_date = Date.tomorrow
      end

      it "should raise an exception" do
        lambda {
          @organisation.take_payment
        }.should raise_error(PaymentNotDueException)
      end

      it "should not try to take any money" do
        Repeat.should_not_receive(:new)
      end
    end

    describe "without a valid payment method" do
      before :each do
        @organisation.stub!(:has_valid_payment_method?).and_return(false)
      end

      it "should raise an exception" do
        lambda {
          @organisation.take_payment
        }.should raise_error(NoPaymentMethod)
      end

      it "should not try to take any money" do
        Repeat.should_not_receive(:new)
      end
    end

    describe "failure to take payment" do
      before :each do
        @repeat = mock_model(Repeat, :successful? => false)
        Repeat.stub!(:create!).and_return(@repeat)
        @user = Users.create_user!
        @payment_method.user = @user
        @payment_method.save!
      end
      
      it "should not change the next payment date" do
        payment_date = @organisation.next_payment_date
        @organisation.take_payment
        @organisation.next_payment_date.should == payment_date
      end

      it "should email the user" do
        UserMailer.should_receive(:deliver_payment_failure).with(@organisation)
        @organisation.take_payment
      end
    end

    describe "billable" do
      before :each do
        @payment_methods = []
        3.times do
          @payment_methods << PaymentMethod.create!(
            :last_four_digits => '1234',
            :user => @user,
            :number => '4242424242424242',
            :card_type => 'visa',
            :verification_value => '123',
            :cardholder_name => 'Joe Bloggs',
            :month => Date.today.month,
            :year => Date.today.year + 1,
            :organisation => @organisation
          )
        end

        @billable_organisation = Organisations.create_organisation!
        @billable_organisation.update_attribute(:next_payment_date, Date.today)
        @payment_methods[0].update_attributes(
          :organisation => @billable_organisation
        )

        @not_due_organisation = Organisations.create_organisation!
        @not_due_organisation.update_attribute(:next_payment_date, Date.tomorrow)
        @payment_methods[1].update_attributes(
          :organisation => @not_due_organisation
        )

        @organisation_without_payment = Organisations.create_organisation!
        @organisation_without_payment.update_attribute(
          :next_payment_date, Date.today
        )

        @suspended_organisation = Organisations.create_organisation!
        @suspended_organisation.update_attribute(:next_payment_date, Date.today)
        @suspended_organisation.update_attribute(:suspended, true)
        @payment_methods[2].update_attributes(
          :organisation => @suspended_organisation
        )
      end

      it "should return organisations due for payment" do
        Organisation.billable.should include(@billable_organisation)
      end

      it "should not return organisations not due for payment" do
        Organisation.billable.should_not include(@not_due_organisation)
      end

      it "should not return organisations without payment methods" do
        Organisation.billable.should_not include(@organisation_without_payment)
      end

      it "should not return suspended organisations" do
        Organisation.billable.should_not include(@suspended)
      end
    end

    it "should include RepeatBilling" do
      Organisation.ancestors.should include(RepeatBilling)
    end
  end

  describe "suspension_date" do
    before :each do
      @organisation = Organisations.create_organisation!
      @organisation.update_attribute(:next_payment_date, Date.today)
    end

    it "should return the next_payment_date + the grace period" do
      @organisation.suspension_date.should ==
        Date.today + OrganisationSuspender::GRACE_PERIOD
    end
  end
end
