Feature: Channels
  In order to administer a chalkle channel
  Admin must be able to see details of their channel agreement with chalkle

Background:
  Given "Joy" is a channel admin
  And the admin "Joy" belongs to the "Wellington" channel
  And the admin "Joy" is authenticated

Scenario: A channel with no details should render correctly
  When they visit the "Channels" tab
  Then they should see their channel "Wellington"
  And they visit the "View" page
  Then they should see the default channel percentage of the "Wellington" channel


