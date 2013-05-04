Feature: Teacher new class form
  In order for chalklers to suggest new ideas for classes
  They must be able to submit them to channel admins

Background:
  Given "Sina" is a chalkler
  And the chalkler "Sina" is authenticated
  And the "Science" category exists

Scenario: Chalkler can submit a new class suggestion
  When they visit the "Suggest a class" page
  And they enter new class suggestion details
  Then they should see the new class suggestion confirmation message

Scenario: Chalkler can select channel if they belong to multiple channels
  Given the chalkler "Sina" belongs to the "Whanau" channel
  When they visit the "Suggest a class" page
  And they enter new class suggestion details with channel
  Then they should see the new class suggestion confirmation message
