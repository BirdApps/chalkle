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
  And they visit the "View" page
  Then they should see this chalkler in the "Wellington" channel

Scenario: Channel admin can not see a chalkler in another channel
  Given there is a chalkler with no details in the "Dunedin" channel
  When they visit the "Chalklers" tab
  Then they should not see this chalkler

Scenario: A chalkler with no details should be editable
  Given there is a chalkler with no details in the "Wellington" channel
  When they visit the "Chalklers" tab
  And they visit the "Edit" page
  Then they should see "Edit Chalkler"

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

Scenario: Channel Admin can see lessons taught by chalkler
  Given "Whetu" is a chalkler
  And the chalkler "Whetu" belongs to the "Wellington" channel
  And "Whetu" is the teacher for the lesson "How to braid your hair"
  When the channel admin views "Whetu's" profile
  Then they should see the lesson "How to braid your hair"

Scenario: Channel Admin can see lessons attended by chalkler
  Given "Whetu" is a chalkler
  And the chalkler "Whetu" belongs to the "Wellington" channel
  And "Whetu" attended the lesson "How to braid your hair 2"
  When the channel admin views "Whetu's" profile
  Then they should see the lesson "How to braid your hair 2"

Scenario: Channel Admin cannot see lessons not attended by chalkler
  Given "Whetu" is a chalkler
  And the chalkler "Whetu" belongs to the "Wellington" channel
  And "Whetu" did not attend the lesson "How to braid your hair 2"
  When the channel admin views "Whetu's" profile
  Then they should not see the lesson "How to braid your hair 2"

Scenario: Comments on chalklers are displayed on the index page
  Given there is a chalkler with no details in the "Wellington" channel
  When they view this chalkler
  And they fill in the chalkler comments with "This is a comment"
  When they return to the chalkler index page
  Then they should see "This is a comment"


Scenario: Channels for chalklers are not shown to channel admins
  Given "Whetu" is a chalkler
  And the chalkler "Whetu" belongs to the "Wellington" channel
  When they edit "Whetu's" profile
  Then they should not see the "join channels" form item 

