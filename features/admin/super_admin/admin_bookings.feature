Feature: Bookings
  In order to administer chalkle
  Admin must be able to create, modify and query bookings made by chalkle members

Background:
  Given "Jill" is a super admin
  And the admin "Jill" is authenticated

Scenario: A booking with no details should render correctly
  Given there is a booking with no details
  When they visit the "Bookings" page
  Then they should see this booking

