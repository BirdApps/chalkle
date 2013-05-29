Feature: Performance
  In order to administer a chalkle channel
  Channel Admin must be able to get a quick overview of the things requiring their attendtion

Background:
  Given "Joy" is a channel admin
  And the admin "Joy" belongs to the "Wellington" channel
  And the admin "Joy" is authenticated

Scenario: Channel admins can see unreviewed lessons from their channel
  Given there is an unreviewed lesson in the "Wellington" channel
  When they visit the "Dashboard" tab
  Then they should see this lesson under the Unreviewed panel

Scenario: Channel admins can not see unreviewed lessons from another channel
  Given there is an unreviewed lesson in the "Dunedin" channel
  When they visit the "Dashboard" tab
  Then they should not see this lesson
