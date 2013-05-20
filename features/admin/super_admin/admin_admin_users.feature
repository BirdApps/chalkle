Feature: Admin Users
  In order to administer chalkle
  Admin must be able to control who has access to what on the chalkle system

Background:
  Given "Jill" is a super admin
  And the admin "Jill" is authenticated

Scenario: An admin user with no details should render correctly
  Given there is an admin user with no details
  When they visit the "Admin Users" page
  Then they should see this admin user

