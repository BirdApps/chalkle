Feature: Chalklers
  In order to administer a chalkle channel
  Channel Admins must be able to contact members of their channels about the classes they are teaching or attending

Background:
  Given "Joy" is a channel admin
  And the admin "Joy" belongs to the "Wellington" channel
  And the admin "Joy" is authenticated

Scenario: A chalkler with no details should render correctly
  Given there is a chalkler with no details in the "Wellington" channel
  When they visit the "Chalklers" tab
  Then they should see this chalkler in the "Wellington" channel

Scenario: Channel Admin can access the new chalkler form
  When they visit the "Chalklers" tab
  Then they should see the "New Chalkler" button
  When they click on the "New Chalkler" button
  Then they should see the New Chalkler form for this channel

Scenario: Channel Admin cannot create a chalkler without a channel
  Given the admin "Joy" belongs to the "Whanau" channel
  When they visit the New Chalkler form
  And they create a chalkler without a channel
  Then they should see an error message

Scenario: Channel Admin with single channel can create a new chalkler in that channel
  When they visit the New Chalkler form
  Then they cannot see channel checkboxes
  When they create a chalkler
  Then a new chalkler is created in the "Wellington" channel
  And the new chalkler will receive a password reset email

Scenario: Channel Admin with two channels can create a chalkler with two channels
  Given the admin "Joy" belongs to the "Whanau" channel
  When they visit the New Chalkler form
  Then they should see channel checkboxes
  When they create a chalkler with two channels
  Then a new chalkler is created with two channels
  And the new chalkler will receive a password reset email

Scenario: Channel Admin can send password reset email for chalklers in their channel
  Given "Whetu" is a chalkler
  And the chalkler "Whetu" belongs to the "Wellington" channel
  When the channel admin views "Whetu's" profile
  And they press the "Send password reset email" button
  Then the chalkler "Whetu" in this channel should receive a password reset email

Scenario: Password reset button is not displayed when chalkler has no email
  Given "Whetu" is a chalkler
  And the chalkler "Whetu" belongs to the "Wellington" channel
  And the chalkler "Whetu" has no email address
  When the channel admin views "Whetu's" profile
  Then channel admin should not see a password reset button