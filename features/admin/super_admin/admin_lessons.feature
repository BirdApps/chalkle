Feature: Lessons
  In order to administer chalkle
  Admin must be able to modify and query all the classes

Background:
  Given "Jill" is a super admin
  And the admin "Jill" is authenticated

Scenario: A lesson with no details should render correctly
  Given there is a lesson with no details
  When they visit the "Lessons" page
  Then they should see this lesson


