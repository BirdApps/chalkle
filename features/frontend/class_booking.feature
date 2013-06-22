Feature: Class bookings
  In order to participate in chalkle activites, chalkler must be able to view and sign up to classes

Background:
  Given "Said" is a chalkler
  And the chalkler "Said" belongs to the "Horowhenua" channel
  And the chalkler "Said" is authenticated
  And there is a class "Test class" open to sign-up

Scenario: Chalkler can see the class being listed
  When they visit the class listings
  Then they should see "Test class"

Scenario: Chalkler can sign up to a class
  When they visit the class listings
  And they press the "Join this class" button
  And they select the payment method "Bank Transfer"
  And they select the number of attendees "2"
  And they agree with the terms and conditions
  And they press the "Confirm booking" button
  Then they should see a summary of this booking

Scenario: Chalkler can re-book a class after cancelling their booking
  Given the chalkler has cancelled an unpaid booking
  When they visit the class listings
  And they press the "Join this class" button
  And they select the payment method "Bank Transfer"
  And they select the number of attendees "2"
  And they agree with the terms and conditions
  And they press the "Confirm booking" button
  Then they should see a summary of this booking

Scenario: Chalkler must still agree with terms and conditions when rebooking a class
  Given the chalkler has cancelled an unpaid booking
  When they visit the class listings
  And they press the "Join this class" button
  And they select the payment method "Bank Transfer"
  And they select the number of attendees "2"
  And they press the "Confirm booking" button
  Then they should see "please read and agree"

Scenario: Booking confirmation shows paid when rebooking a paid class
  Given the chalkler has cancelled a paid booking
  When they visit the class listings
  And they press the "Join this class" button
  And they select the payment method "Bank Transfer"
  And they select the number of attendees "2"
  And they agree with the terms and conditions
  And they press the "Confirm booking" button
  Then they should see "Payment received, thanks!"