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

Scenario: Admin with two channels can create a chalkler with two channels
  Given the admin "John" belongs to the "Whanau" channel
  When they visit the New Chalkler form
  Then they should see channel checkboxes
  When they create a chalkler with two channels
  Then a new chalkler is created with two channels

Scenario: Admin with single channel can create a new chalkler
  When they visit the New Chalkler form
  Then they cannot see channel checkboxes
  When they create a chalkler
  Then a new chalkler is created with one channel

Scenario: Admin cannot create a chalkler without a channel
  Given the admin "John" belongs to the "Whanau" channel
  When they visit the New Chalkler form
  And they create a chalkler without a channel
  Then they should see an error message