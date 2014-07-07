Feature: Performance
  In order to administer a chalkle channel
  Channel Admin must be able to get a quick overview of the things requiring their attendtion

Background:
  Given "Joy" is a channel admin
  And the admin "Joy" belongs to the "Wellington" channel
  And the admin "Joy" is authenticated

Scenario: Channel admins can see unreviewed courses from their channel
  Given there is an unreviewed course in the "Wellington" channel
  When they visit the "Dashboard" tab
  Then they should see this course under the "Unreviewed classes" panel

Scenario: Channel admins can not see unreviewed courses from another channel
  Given there is an unreviewed course in the "Dunedin" channel
  When they visit the "Dashboard" tab
  Then they should not see this course

Scenario: Channel admins can see classes being processed from their channel
  Given there is a course in the "Wellington" channel being processed
  When they visit the "Dashboard" tab
  Then they should see this course under the "Classes being processed" panel

Scenario: Channel admins can see approved course from their channel
  Given there is an approved course in the "Wellington" channel 
  When they visit the "Dashboard" tab
  Then they should see this course under the "Approved classes" panel

Scenario: Channel admins can see on-hold courses from their channel
  Given there is an on-hold course in the "Wellington" channel 
  When they visit the "Dashboard" tab
  Then they should see this course under the "On-hold classes" panel

Scenario: Channel admins can see courses coming up next week
  Given there is course in the "Wellington" channel coming up this week
  When they visit the "Dashboard" tab
  Then they should see this course under the "Coming up this week" panel

Scenario: Channel admins can see May Cancel alert when a class doesn't reach its minimum
  Given there is course in the "Wellington" channel coming up this week with minimum attendee of "10"
  And the number of RSVPs is "2"
  When they visit the "Dashboard" tab
  Then they should see "May Cancel"

Scenario: Channel admins can see Missing Details alert when a class has missing details
  Given there is course in the "Wellington" channel coming up this week with no teacher cost
  When they visit the "Dashboard" tab
  Then they should see "Missing Details"