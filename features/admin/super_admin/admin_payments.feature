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