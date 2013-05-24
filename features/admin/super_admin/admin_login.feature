Feature: Login
  In order to use the admin area
  Super Admins must be able to log in

  Background:
    Given "Jill" is a super admin

  Scenario: Super admin login
    When the super admin "Jill" logs in
    Then they should be logged in as super admin

  Scenario: Invalid Password
    When the super admin "Jill" logs in with an incorrect password
    Then they should not be logged in as super admin
