Feature: Lessons
  In order to administer a chalkle channel
  Channel Admin must be able to bring to life all different classes that chalklers want

Background:
  Given "Joy" is a channel admin
  And the admin "Joy" belongs to the "Wellington" channel
  And the admin "Joy" is authenticated

Scenario: A lesson with no details should render correctly
  Given there is a lesson with no details in the "Wellington" channel
  When they visit the "Lessons" page
  Then they should see this lesson in the "Wellington" channel


