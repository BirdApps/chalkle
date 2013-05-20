Feature: Chalklers
  In order to administer chalkle
  Super Admins must be able to create, modify and query all the chalkle members (aka chalklers)

Background:
  Given "Jill" is a super admin
  And the admin "Jill" belongs to the "Wellington" channel
  And the admin "Jill" is authenticated

Scenario: A chalkler with no details should render correctly
  Given there is a chalkler with no details
  When they visit the "Chalklers" page
  Then they should see this chalkler

Scenario: Super Admin can access the new chalkler form
  When they visit the Chalklers index page
  Then they should see the "New Chalkler" button
  When they click on the "New Chalkler" button
  Then they should see the New Chalkler form

Scenario: Super Admin cannot create a chalkler without a channel
  Given the admin "Jill" belongs to the "Whanau" channel
  When they visit the New Chalkler form
  And they create a chalkler without a channel
  Then they should see an error message

Scenario: Super Admin with single channel can create a new chalkler in that channel
  When they visit the New Chalkler form
  Then they cannot see channel checkboxes
  When they create a chalkler
  Then a new chalkler is created with one channel
  And the new chalkler will receive a password reset email

Scenario: Super Admin with two channels can create a chalkler with two channels
  Given the admin "Jill" belongs to the "Whanau" channel
  When they visit the New Chalkler form
  Then they should see channel checkboxes
  When they create a chalkler with two channels
  Then a new chalkler is created with two channels
  And the new chalkler will receive a password reset email

Scenario: Super Admin can send password reset email for all chalklers
  Given "Whetu" is a chalkler
  When the admin views "Whetu's" profile
  And they trigger a password reset email
  Then the chalkler "Whetu" should receive a password reset email

Scenario: Password reset button is not displayed when chalkler has no email
  Given "Whetu" is a chalkler
  And the chalkler "Whetu" has no email address
  When the admin views "Whetu's" profile
  Then there should be no password reset button