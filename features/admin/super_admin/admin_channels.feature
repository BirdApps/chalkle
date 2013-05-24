Feature: Channels
  In order to administer chalkle
  Admin must be able to manage all the channels that use the chalkle platform

Background:
  Given "Jill" is a super admin
  And the admin "Jill" is authenticated

Scenario: A channel with no details should render correctly
  Given there is a channel with no details
  When they visit the "Channels" tab
  Then they should see this channel
  And they visit the "View" page
  Then they should see this channel


