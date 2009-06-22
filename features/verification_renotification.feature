Feature: Verification Re-notification
  As an unverified user who has lost his verification email
  I want to be able to resend my verification email
  So that I can log in

  Scenario: Follow link from log in
    Given I am on the log in page
    When I follow "Re-send Verification Email"
    Then I should see "Please enter your email address"

  Scenario: Submit email address for unverified user
    Given I am an unverified user with email address "bob@nicenose.biz"
    And I am on the re-send verification email page
    When I fill in "Email address" with "bob@nicenose.biz"
    And I press "Send"
    Then I should see "Verification Email Sent"
    And I should receive a new verification email at "bob@nicenose.biz"
