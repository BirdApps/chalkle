Feature: Login
  In order to use the admin area
  Admins must be able to log in

  Background:
    Given "Jill" is a channel admin

  Scenario: Channel admin login
    When the admin "Jill" logs in
    Then they should be logged in

  Scenario: Invalid Password
    When the admin "Jill" logs in with an incorrect password
    Then they should not be logged in
