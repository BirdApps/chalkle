Feature: Chalkler Admin
  In order to manage a chalkle channel
  Admins must be able to view, create, edit and update the chalkle membership
  database for that channel

Background:
  Given "John" is a channel admin
  And the admin "John" belongs to the "Wellington" channel
  And the admin "John" is authenticated

Scenario: Admin can access the new chalkler form
  When they visit the Chalklers index page
  Then they should see the "New Chalkler" button
  When they click on the "New Chalkler" button
  Then they should see the New Chalkler form

Scenario: Admin with two channels can create a chalkler with two channels
  Given the admin "John" belongs to the "Whanau" channel
  When they visit the New Chalkler form
  Then they should see channel checkboxes
  When they create a chalkler with two channels
  Then a new chalkler is created with two channels
  And the new chalkler will receive a password reset email

Scenario: Admin with single channel can create a new chalkler
  When they visit the New Chalkler form
  Then they cannot see channel checkboxes
  When they create a chalkler
  Then a new chalkler is created with one channel
  And the new chalkler will receive a password reset email

Scenario: Admin cannot create a chalkler without a channel
  Given the admin "John" belongs to the "Whanau" channel
  When they visit the New Chalkler form
  And they create a chalkler without a channel
  Then they should see an error message

Scenario: Admin can send password reset email
  Given "Whetu" is a chalkler
  And the chalkler "Whetu" belongs to the "Wellington" channel
  When the admin views "Whetu's" profile
  And they trigger a password reset email
  Then the chalkler "Whetu" should receive a password reset email

Scenario: Password reset button is not displayed when chalkler has no email
  Given "Whetu" is a chalkler
  And the chalkler "Whetu" has no email address
  And the chalkler "Whetu" belongs to the "Wellington" channel
  When the admin views "Whetu's" profile
  Then there should be no password reset button