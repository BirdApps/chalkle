Feature: Bookings
  In order to administer a chalkle channel
  Channel Admins must be able to alter bookings on behalf of chalklers

Background:
  Given "Joy" is a channel admin
  And the admin "Joy" belongs to the "Wellington" channel
  And the admin "Joy" is authenticated

Scenario: A booking with no details should render correctly
  Given there is a booking with no details in the "Wellington" channel
  When they visit the "Bookings" tab
  Then they should see this booking in the "Wellington" channel
  And they visit the "View" page
  Then they should see this booking in the "Wellington" channel

Scenario: A booking with no details should be editable
  Given there is a booking with no details in the "Wellington" channel
  When they visit the "Bookings" tab
  And they visit the "Edit" page
  Then they should see "Edit Booking"
