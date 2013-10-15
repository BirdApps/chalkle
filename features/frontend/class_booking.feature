Feature: Class bookings
  In order to participate in chalkle activites, chalkler must be able to view
  and sign up to classes

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
  And select the first class
  And they press the "Join this class" button
  And they select the payment method "Bank Transfer"
  And they select the number of attendees "2"
  And they agree with the terms and conditions
  And they press the "Confirm booking" button
  Then they should see a summary of this booking

#Scenario: Chalkler can sign up to a class via online payment
#  When they visit the class listings
#  And they press the "Join this class" button
#  And they select the payment method "Credit Card"
#  And they select the number of attendees "2"
#  And they agree with the terms and conditions
#  And they press the "Confirm booking" button
#  Then they should see the online payment form

Scenario: A cancelled booking can be rebooked
  Given the chalkler "Said" has cancelled a booking
  When they visit an open class
  Then they should see "Join this class"
  When they press the "Join this class" button
  And they fill out the booking form
  Then they should see "Booking created!"
  And their booking should be updated
