require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UserMailer do
  describe "verification" do
    before :each do
      @user = Users.create_user!(:signup => true)
      @mail = UserMailer.create_verification(@user)
    end

    it "should set the subject" do
      @mail.subject.should == "Please verify your Simply Agile account"
    end

    it "should set the recipient" do
      @mail.to.should == [@user.email_address]
    end

    it "should set the from" do
      @mail.from.should == ['support@besimplyagile.com']
    end
  end

  describe "acknowledgement" do
    before :each do
      @sponsor = Users.create_user!
      @organisation = @sponsor.organisations.first

      @user = Users.create_user!

      @organisation_member = @organisation.members.create!(
        :user => @user,
        :sponsor => @sponsor
      )
      @mail = UserMailer.create_acknowledgement(@organisation_member)
    end

    it "should set the subject" do
      @mail.subject.should == "You have been added to #{@organisation.name}"
    end

    it "should set the recipient" do
      @mail.to.should == [@user.email_address]
    end

    it "should set the from" do
      @mail.from.should == ['support@besimplyagile.com']
    end
  end

  describe "payment failure" do
    before :each do
      stub_payment_gateway
      @user = Users.create_user!
      @organisation = Organisations.create_organisation!
      @organisation.update_attribute(:next_payment_date, Date.today)
      @payment_method = PaymentMethod.create!(
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

      @mail = UserMailer.create_payment_failure(@organisation)
    end

    it "should set the subject" do
      @mail.subject.should == "Payment failed for #{@organisation.name}"
    end

    it "should set the recipient" do
      @mail.to.should == [@user.email_address]
    end

    it "should set the from" do
      @mail.from.should == ['support@besimplyagile.com']
    end
  end
end
