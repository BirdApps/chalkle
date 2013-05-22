Feature: Chalklers
  In order to administer chalkle
  Super Admins must be able to understand chalkle members (aka chalklers) through their activities on the chalkle platform

Background:
  Given "Jill" is a super admin
  And the admin "Jill" belongs to the "Wellington" channel
  And the admin "Jill" is authenticated

Scenario: A chalkler with no details should render correctly
  Given there is a chalkler with no details
  When they visit the "Chalklers" page
  Then they should see this chalkler

Scenario: Super Admin can access the new chalkler form
  When they visit the "Chalklers" tab
  Then they should see the "New Chalkler" button
  When they click on the "New Chalkler" button
  Then they should see the New Chalkler form

Scenario: Super Admin can send password reset email for all chalklers
  Given "Whetu" is a chalkler
  When the super admin views "Whetu's" profile
  And they press the "Send password reset email" button
  Then the chalkler "Whetu" should receive a password reset email

Scenario: Password reset button is not displayed when chalkler has no email
  Given "Whetu" is a chalkler
  And the chalkler "Whetu" has no email address
  When the super admin views "Whetu's" profile
  Then super admin should not see a password reset button