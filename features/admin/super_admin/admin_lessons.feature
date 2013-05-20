Feature: Lessons
  In order to administer chalkle
  Super Admin must be able to bring to life all different classes that chalklers want

Background:
  Given "Jill" is a super admin
  And the admin "Jill" is authenticated

Scenario: A lesson with no details should render correctly
  Given there is a lesson with no details
  When they visit the "Lessons" page
  Then they should see this lesson


