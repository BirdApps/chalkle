Feature: Dashboard
  In order to administer a chalkle
  Super Admin must be able to get a quick overview of the things requiring their attendtion

Background:
  Given "Jill" is a super admin
  And the admin "Jill" is authenticated

Scenario: Super admin can see links to email students about missing payment
  Given there is a paid class coming up
  And there is an unpaid booking for this class
  When they visit the "Dashboard" tab
  Then they should see the link "Email students"

Scenario: Super admin can see links to email teachers with attendee list
  Given there is a paid class tomorrow
  When they visit the "Dashboard" tab
  Then they should see the link "Email teacher"

Scenario: Super admin can see links to email teacher with payment summary
  Given there was a paid class yesterday
  When they visit the "Dashboard" tab
  Then they should see the link "Email teacher"

Scenario: Super admin can see links to email students about classes that will be cancelled
  Given there is a paid class coming up
  And the number of bookings have not reached the minimum required
  When they visit the "Dashboard" tab
  Then they should see the link "Email them"
