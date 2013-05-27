Feature: Admin Users
  In order to administer chalkle
  Super admins must be able to control who has access to what on the chalkle system

Background:
  Given "Jill" is a super admin
  And the admin "Jill" is authenticated

Scenario: An admin user with no details should render correctly
  Given there is an admin user with no details
  When they visit the "Admin Users" tab
  Then they should see this admin user
  And they visit the "View" page of this admin user
  Then they should see this admin user

Scenario: An admin user with no details should be editable
  Given there is an admin user with no details
  When they visit the "Admin Users" tab
  And they visit the "Edit" page of this admin user
  Then they should see "Edit Admin User"

