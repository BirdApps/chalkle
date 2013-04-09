Feature: Teacher new class form
  In order for chalklers to suggest new classes
  They must be able to submit them to channel admins

Background:
  Given "Sina" is a chalkler
  And the chalkler "Sina" is authenticated
  And the chalkler "Sina" belongs to the "Wellington" channel
  And the "Science" category exists

Scenario: Chalkler can submit a new class
  When they visit the "Teach" page
  And they enter new class details
  Then they should see the new class confirmation message
  And the "Wellington" channel email link will be displayed

Scenario: Chalkler can select channel if they belong to multiple channels
  Given the chalkler "Sina" belongs to the "Whanau" channel
  When they visit the "Teach" page
  And they enter new class details with channel
  Then they should see the new class confirmation message
  And the "Whanau" channel email link will be displayed