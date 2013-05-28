Feature: Performance
  In order to administer a chalkle channel
  Channel Admin must be able to see trends in the activities within their channel

Background:
  Given "Joy" is a channel admin
  And the admin "Joy" belongs to the "Wellington" channel
  And the admin "Joy" is authenticated

Scenario: Channel admin can not see the performance of another channel
  Given there is an active channel called "Dunedin"
  When they visit the "Performance" tab
  Then they should not see the performance panel of "Dunedin"
