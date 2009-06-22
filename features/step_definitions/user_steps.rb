require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))

Given /^I am an unverified user with email address "(.*)"$/ do |email_address|
  user = User.new :verified => false, :email_address => email_address
  user.save(verify = false)
end

Then /^I should have received a new verification email$/ do
  Then 'I should receive an email'
  When 'I open the email'
  Then 'I should see "verify this email address"'
end

