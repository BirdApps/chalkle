Feature: Trash
  In order to administer a chalkle channel
  Channel Admin must be able to correct deletion mistakes without outside assistance

Background:
  Given "Joy" is a channel admin
  And the admin "Joy" belongs to the "Wellington" channel
  And the admin "Joy" is authenticated

Scenario: A deleted lesson with no details should render correctly
  Given there is a deleted lesson with no details in the "Wellington" channel
  When they visit the "Trash" tab
  Then they should see this lesson in the trash list
  And they visit the "View" page
  Then they should see this lesson

Scenario: Channel admin can not see a deleted lesson from another channel
  Given there is a deleted lesson with no details in the "Dunedin" channel
  When they visit the "Trash" tab
  Then they should not see this lesson 

Scenario: A deleted lesson with no details should be restorable
  Given there is a deleted lesson with no details in the "Wellington" channel
  When they visit the "Trash" tab
  And they visit the "View" page
  And they press the "Restore record" button
  Then this lesson should be undeleted
