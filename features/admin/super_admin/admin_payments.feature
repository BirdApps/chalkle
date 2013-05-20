Feature: Payments
  In order to administer chalkle
  Admin must be able to track payments made for chalkle classes

Background:
  Given "Jill" is a super admin
  And the admin "Jill" is authenticated

Scenario: A payment with no details should render correctly
  Given there is an unreconciled payment with no details
  When they visit the "Payments" page
  Then they should see this payment
