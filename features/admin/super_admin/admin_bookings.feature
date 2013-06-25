Feature: Bookings
  In order to administer chalkle
  Super Admin must be able to create, modify and query bookings made by all chalkle members

Background:
  Given "Jill" is a super admin
  And the admin "Jill" is authenticated

Scenario: A booking with no details should render correctly
  Given there is a booking with no details
  When they visit the "Bookings" tab
  Then they should see this booking
  And they visit the "View" page
  Then they should see this booking

Scenario: A booking with no details should be editable
  Given there is a booking with no details
  When they visit the "Bookings" tab
  And they visit the "Edit" page
  Then they should see "Edit Booking"

Scenario: Super admins can delete a booking from any channel
  Given there is a booking with no details
  When they visit the "Bookings" tab
  And they visit the "View" page
  And they press the "Delete Booking" button
  Then this booking should be deleted

Scenario: A booking with no details should be editable
  Given there is a booking with no details
  When they visit the "Bookings" tab
  And they visit the "Edit" page
  Then they should see "Edit Booking"

Scenario: Super admins can not delete a paid booking from any channel
  Given there is a paid booking
  When they visit the "Bookings" tab
  And they visit the "View" page
  Then they should not see the "Delete Bookings" button

Scenario: Super admins can not delete a paid booking by the teacher of the class
  Given there is a paid booking by the teacher of the class
  When they visit the "Bookings" tab
  And they visit the "View" page
  Then they should see the "Delete Bookings" button