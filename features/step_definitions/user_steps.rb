require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))

Given /^I am an unverified user with email address "(.*)"$/ do |email_address|
  begin
    User.find_by_email_address(email_address).destroy
  rescue NoMethodError
  end
  user = User.new(:signup => false, :email_address => email_address)
  user.save(validate = false)
  user.update_attribute(:verified, false)
  user.update_attribute(:verify_by, 20.days.from_now)
end

Given /^I am a verified user with email address "(.*)"$/ do |email_address|
  begin
    User.find_by_email_address(email_address).destroy
  rescue NoMethodError
  end
  user = User.new :verified => true, :email_address => email_address,
    :verify_by => 2.days.from_now
  user.save(validate = false)
end

Then /^I should receive a new verification email at "(.*)"$/ do |email_address|
  unread_emails_for(email_address).size.should == 1
  open_email(email_address)
  current_email.should have_subject('Please verify your Simply Agile account')
end

