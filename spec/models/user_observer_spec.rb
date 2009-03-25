require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UserObserver do
  describe "new user, new organisation" do
    before :each do
      @user = User.new(Users.user_prototype)
    end

    it "should send a verification email" do
      User.with_observers(:user_observer) do
        UserMailer.should_receive(:deliver_verification).with(@user)
        @user.save
      end
    end

    it "should not send an authorisation email" do
      User.with_observers(:user_observer) do
        UserMailer.should_not_receive(:deliver_acknowledgement)
        @user.save
      end
    end
  end
end