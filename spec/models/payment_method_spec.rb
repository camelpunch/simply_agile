require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PaymentMethod do
  before(:each) do
    ActiveMerchant::Billing::Base.mode = :test
    stub_payment_gateway
  end

  describe "setting the year" do
    before :each do
      @payment_method = PaymentMethod.new
    end

    describe "as 09" do
      it "should be 2009" do
        @payment_method.year = '09'
        @payment_method.year.should == 2009
      end
    end

    describe "as ''" do
      it "should be blank" do
        @payment_method.year = ''
        @payment_method.year.should be_blank
      end
    end
  end

  describe "setting the card number" do
    before :each do
      @payment_method = PaymentMethod.new
    end

    describe "as 4242 4242 4242 4242" do
      it "should be 4242424242424242" do
        @payment_method.number = '4242 4242 4242 4242'
        @payment_method.number.should == '4242424242424242'
      end
    end
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

  describe "has_expired?" do
    before :each do
      today = Date.today
      @before = PaymentMethods.create_payment_method!
      @before.update_attribute(:month, today.month - 1)
      @before.update_attribute(:year, today.year)

      @this_month = PaymentMethods.create_payment_method!
      @this_month.update_attribute(:month, today.month)
      @this_month.update_attribute(:year, today.year)

      @future = PaymentMethods.create_payment_method!
      @future.update_attribute(:month, today.month + 1)
      @future.update_attribute(:year, today.year)
    end

    it "should be set if expiry month is before this month" do
      @before.should have_expired
    end

    it "should not be set if expiry month is this month" do
      @this_month.should_not have_expired
    end

    it "should not be set if expiry month is in the future" do
      @future.should_not have_expired
    end
  end

  describe "creation" do
    before :each do
      @payment_method = PaymentMethods.create_payment_method!(
        :number => 1111222233334444
      )
      @payment_method.save
    end

    it "should set the last four digits" do
      @payment_method.last_four_digits.should == 4444
    end
  end

  describe "test_payment" do
    before :each do
      @payment_method = PaymentMethod.new
    end

    it "should create a new authorization" do
      authorisation_count = Authorisation.count
      @payment_method.test_payment
      Authorisation.count.should == authorisation_count + 1
    end

    it "should store the repeat_payment_token" do
      @payment_method.test_payment
      last_payment = Payment.find(:last, :order => 'id')
      @payment_method.repeat_payment_token.should ==
        last_payment.reference
    end

    it "should create a new void" do
      void_count = Void.count
      @payment_method.test_payment
      Void.count.should == void_count + 1
    end

    describe "when authorisation payment reference is blank" do
      it "should return false" do
        authorisation = mock_model(Authorisation,
                                   :payment => mock_model(Payment,
                                                          :reference => ''))
        Authorisation.stub!(:create).and_return(authorisation)
        Authorisation.stub!(:create!).and_return(authorisation)
        @payment_method.test_payment.should == false
      end
    end
  end

  describe "validations" do
    before :each do
      @payment_method = PaymentMethod.new
      @payment_method.stub!(:test_payment)
      @payment_method.valid?
    end

    it "should require a card type" do
      @payment_method.should have(1).error_on(:card_type)
    end

    it "should require that card type is with CARD_TYPES" do
      @payment_method.card_type = 'Delta'
      @payment_method.valid?
      @payment_method.should have(1).error_on(:card_type)
    end

    it "should require a cardholder name" do
      @payment_method.should have(1).error_on(:cardholder_name)
    end

    it "should require a card number" do
      @payment_method.should have(1).error_on(:number)
    end

    it "should require that card number is well formed" do
      @payment_method.number = 'aaaaaaa'
      @payment_method.valid?
      @payment_method.should have(1).error_on(:number)
    end

    it "should require an expiry year" do
      @payment_method.should have(1).error_on(:year)
    end

    it "should require an expiry month" do
      @payment_method.should have(1).error_on(:month)
    end

    it "should require expiry month to be in the future" do
      $debug = 1
      @payment_method.year = Date.today.year
      @payment_method.month = Date.today.month - 1
      @payment_method.valid?
      @payment_method.should have(1).error_on(:month)
    end

    it "should require a security code" do
      @payment_method.should have(1).error_on(:verification_value)
    end
  end

  describe "card types" do
    it "should return visa and mastercard" do
      PaymentMethod::CARD_TYPES.should == ['mastercard', 'visa']
    end
  end

  describe "credit_card" do
    before :each do
      @payment_method = PaymentMethods.create_payment_method!(
        :cardholder_name => 'Joe Bloggs'
      )
      @credit_card = @payment_method.credit_card
    end

    it "should return a credit card object" do
      @credit_card.should be_kind_of(ActiveMerchant::Billing::CreditCard)
    end

    it "should memoize" do
      @payment_method.instance_variable_set('@credit_card', nil)
      @payment_method.stub!(:create_credit_card).and_return('first', 'second')
      @payment_method.credit_card
      @payment_method.credit_card.should == 'first'
    end

    it "should set the number" do
      @credit_card.number.should == @payment_method.number
    end

    it "should set the month" do
      @credit_card.month.should == @payment_method.month
    end

    it "should set the year" do
      @credit_card.year.should == @payment_method.year
    end

    it "should set the verification_value" do
      @credit_card.verification_value.should == @payment_method.verification_value
    end

    it "should set the first name" do
      @credit_card.first_name.should == "Joe"
    end

    it "should set the last name" do
      @credit_card.last_name.should == "Bloggs"
    end

    it "should set the card type" do
      @credit_card.type.should == "visa"
    end

    it "should be valid" do
      @credit_card.should be_valid
    end
  end
end
