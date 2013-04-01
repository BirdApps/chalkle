Feature: Login
  In order to use the admin area
  Admins must be able to log in

  Scenario: Channel admin login
    Given "test@chalkle.com" is a channel admin
    When I login as "test@chalkle.com"
    Then I should be logged in

  Scenario: Not an admin
    When I login as "none@chalkle.com"
    Then I should not be logged in

  Scenario: Invalid Password
    Given "test@chalkle.com" is a channel admin
    When I login as "test@chalkle.com" with an incorrect password
    Then I should not be logged in

  Scenario: Password reset
    Given "test@chalkle.com" received a password reset token
    When I click on the link
    Then I should be able to change my passwords
    Then I should be logged in
