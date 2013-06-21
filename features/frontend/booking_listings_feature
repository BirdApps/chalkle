Feature: Booking listings
  In order to join classes, chalklers must be able to view their bookings

Background:
  Given "Said" is a chalkler
  And the chalkler "Said" is authenticated
  And the chalkler "Said" has booked a class

Scenario: Chalkler can view their unpaid bookings
  When they visit the bookings page
  Then the unpaid booking should be displayed

Scenario: Chalkler can view their paid upcoming bookings
  Given the chalkler "Said" has paid their booking
  When they visit the bookings page
  Then the paid booking should be displayed

Scenario: Free classes should automatically be confirmed
  Given the chalkler "Said" has booked a free class
  When they visit the bookings page
  Then the free booking will be displayed under "Confirmed classes"

Scenario: Old paid bookings will be hidden from listings
  Given the chalkler "Said" has been to a class already
  When they visit the bookings page
  Then their booking should not be displayed

Scenario: Bookings with status not equal to "yes" will be hidden from listings
  Given the chalkler "Said" has changed her status to "no"
  When they visit the bookings page
  Then their booking should not be displayed

Scenario: Chalkler can cancel an unpaid booking
  When they visit the bookings page
  And they press the "Cancel booking" button
  Then they should see "Are you sure you want to cancel"
  When they press the "Yes" button
  Then they should see "Your booking is cancelled"

Scenario: Chalkler can cancel a paid booking for a class more than 3 days away and receive refund instructions
  Given the chalkler "Said" has paid their booking for a class next week
  When they visit the bookings page
  And they press the "Cancel booking" button
  Then they should see "Please email Accounts"
  When they press the "Yes" button
  Then they should see "Your booking is cancelled"

Scenario: Chalkler can cancel a paid booking for a class less than 3 days away and is told there will be no refund
  Given the chalkler "Said" has paid their booking
  When they visit the bookings page
  And they press the "Cancel booking" button
  Then they should see "you will not be eligible for a refund"
  When they press the "Yes" button
  Then they should see "Your booking is cancelled"
