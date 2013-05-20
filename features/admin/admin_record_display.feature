Feature: Display database records
  In order to administer chalkle
  Admin must be able to see database records even in their most basic state

Background:
  Given "Jill" is a super admin
  And the admin "Jill" is authenticated

Scenario: A payment with no details should render correctly
  Given there is an unreconciled payment with no details
  When they visit the "Payments" page
  Then they should see this payment

Scenario: A lesson with no details should render correctly
  Given there is a lesson with no details
  When they visit the "Lessons" page
  Then they should see this lesson

