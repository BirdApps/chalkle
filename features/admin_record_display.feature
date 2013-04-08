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

Scenario: A channel with no details should render correctly
  Given there is a channel with no details
  When they visit the "Channels" page
  Then they should see this channel

Scenario: A chalkler with no details should render correctly
  Given there is a chalkler with no details
  When they visit the "Chalklers" page
  Then they should see this chalkler

Scenario: A categories with no details should render correctly
  Given there is a category with no details
  When they visit the "Categories" page
  Then they should see this category

Scenario: A booking with no details should render correctly
  Given there is a booking with no details
  When they visit the "Bookings" page
  Then they should see this booking

Scenario: An admin user with no details should render correctly
  Given there is an admin user with no details
  When they visit the "Admin Users" page
  Then they should see this admin user
