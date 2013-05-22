Feature: Lessons
  In order to administer chalkle
  Super Admin must be able to record transactions for each class and query classes across all chalkle channels

Background:
  Given "Jill" is a super admin
  And the admin "Jill" is authenticated

Scenario: A lesson with no details should render correctly
  Given there is a lesson with no details
  When they visit the "Lessons" tab
  Then they should see this lesson


