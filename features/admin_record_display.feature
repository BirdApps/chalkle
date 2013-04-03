Feature: Display database records
  In order to administer chalkle
  Admin must be able to see database records even in their most basic state

Scenario: A payment with no details should render correctly
  Given I am logged in with the "super" role
  And there is an unreconciled payment with no details
  When I visit the "Payments" page
  Then I should see this payment

Scenario: A lesson with no details should render correctly
  Given I am logged in with the "super" role
  And there is a lesson with no details
  When I visit the "Lessons" page
  Then I should see this lesson

Scenario: A channel with no details should render correctly
  Given I am logged in with the "super" role
  And there is a channel with no details
  When I visit the "Channels" page
  Then I should see this channel

Scenario: A chalkler with no details should render correctly
  Given I am logged in with the "super" role
  And there is a chalkler with no details
  When I visit the "Chalklers" page
  Then I should still see this chalkler

Scenario: A categories with no details should render correctly
  Given I am logged in with the "super" role
  And there is a category with no details
  When I visit the "Categories" page
  Then I should still see this category

Scenario: A booking with no details should render correctly
  Given I am logged in with the "super" role
  And there is a booking with no details
  When I visit the "Bookings" page
  Then I should still see this booking

Scenario: An admin user with no details should render correctly
  Given I am logged in with the "super" role
  And there is an admin user with no details
  When I visit the "Admin Users" page
  Then I should still see this admin user

Scenario: Dashboard should render correctly with no records
  Given I am logged in with the "super" role
  And there is a booking with no details
  When I visit the "Dashboard" page
  Then I should see the dashboard
