require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))

Given /^I am an unverified user with email address "(.*)"$/ do |email_address|
  user = User.new :verified => false, :email_address => email_address,
    :verify_by => 2.days.from_now
  user.save(verify = false)
end

Then /^I should receive a new verification email at "(.*)"$/ do |email_address|
  unread_emails_for(email_address).size.should == 1
  open_email(email_address)
  current_email.should have_subject('Please verify your Simply Agile account')
end

