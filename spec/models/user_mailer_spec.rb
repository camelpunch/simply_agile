require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UserMailer do
  describe "verification" do
    before :each do
      @user = Users.create_user!
      @mail = UserMailer.create_verification(@user)
    end

    it "should set the subject" do
      @mail.subject.should == "Please verify your Simply Agile account"
    end

    it "should set the recipient" do
      @mail.to.should == [@user.email_address]
    end

    it "should set the from" do
      @mail.from.should == ['noreply@jandaweb.com']
    end
  end

  describe "authorisation" do
    before :each do
      @sponsor = Users.create_user!
      @user = Users.create_user!(
        :sponsor => @sponsor,
        :organisation => @sponsor.organisation
      )
      @mail = UserMailer.create_authorisation(@user)
    end

    it "should set the subject" do
      @mail.subject.should == "You have been added to #{@user.organisation.name}"
    end

    it "should set the recipient" do
      @mail.to.should == [@user.email_address]
    end

    it "should set the from" do
      @mail.from.should == ['noreply@jandaweb.com']
    end
  end
end