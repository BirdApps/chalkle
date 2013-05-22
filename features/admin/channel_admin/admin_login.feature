Feature: Login
  In order to use the admin area
  Channel admins must be able to log in

  Background:
    Given "Joy" is a channel admin

  Scenario: Channel admin login
    When the channel admin "Joy" logs in
    Then they should be logged in as channel admin

  Scenario: Invalid Password
    When the channel admin "Joy" logs in with an incorrect password
    Then they should not be logged in as channel admin
