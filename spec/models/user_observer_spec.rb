require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UserObserver do
  describe "unverified users" do
    before :each do
      @user = User.new(Users.user_prototype)
      @user.signup = true
    end

    it "should be sent a verification email" do
      User.with_observers(:user_observer) do
        UserMailer.should_receive(:deliver_verification).with(@user)
        @user.save
      end
    end
  end

  describe "verified users" do
    before :each do
      @user = User.new(Users.user_prototype)
      @user.signup = false
    end

    it "should not be sent a verification email" do
      User.with_observers(:user_observer) do
        UserMailer.should_not_receive(:deliver_verification).with(@user)
        @user.save
      end
    end
  end
end