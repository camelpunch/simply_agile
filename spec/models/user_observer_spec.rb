require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UserObserver do
  it "should send a verification email" do
    user = User.new(Users.user_prototype)
    User.with_observers(:user_observer) do
      UserMailer.should_receive(:deliver_verification).with(user)
      user.save
    end
  end
end