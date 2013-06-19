Feature: Payments
  In order to administer chalkle
  Super Admin must be able to track the financial performance of chalkle channels

Background:
  Given "Jill" is a super admin
  And the admin "Jill" is authenticated

Scenario: A payment with no details should render correctly
  Given there is an unreconciled payment with no details
  When they visit the "Payments" tab
  Then they should see this payment
  And they visit the "View" page
  Then they should see this payment

Scenario: A payment with no details should be editable
  Given there is an unreconciled payment with no details
  When they visit the "Payments" tab
  And they visit the "Edit" page
  Then they should see "Edit Payment"

Scenario: Comments on payments should be shown on index page
  Given there is an unreconciled payment with no details
  And they click into this payment
  And they fill in the comments with "This is a comment"
  When they return to the payment index page
  Then they should see "This is a comment"

Scenario: Super admins can delete an unreconciled payment from any channel
  Given there is an unreconciled payment with no details
  When they visit the "Payments" tab
  And they visit the "View" page
  And they press the "Delete Payment" button
  Then this payment should be deleted

Scenario: Super admins can not delete a reconciled payment from any channel
  Given there is a reconciled payment
  When they visit the "Payments" tab
  And they visit the "View" page
  Then they should not see the "Delete Payment" button

Scenario: Super admins can reconcile payments to bookings
  Given there is an ureconciled payment
  When they visit the "Payments" tab
  And they click to reconcile payments
  Then they should see this payment
  And they select the matching booking from the drop down
  Then this payment should be reconciled