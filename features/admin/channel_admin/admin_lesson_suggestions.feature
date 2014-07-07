Feature: Channels
  In order to administer a chalkle channel
  Admin must be able to know what classes chalklers are interested in

Background:
  Given "Joy" is a channel admin
  And the admin "Joy" belongs to the "Wellington" channel
  And the admin "Joy" is authenticated

Scenario: A course suggestion with no details should render correctly
  Given there is a course suggestion with no details in the "Wellington" channel
  When they visit the "Course Suggestions" tab
  Then they should see this course suggestion in the "Wellington" channel
  And they visit the "View" page
  Then they should see this course suggestion in the "Wellington" channel

Scenario: A course suggestion with no details should be editable
  Given there is a course suggestion with no details in the "Wellington" channel
  When they visit the "Course Suggestions" tab
  And they visit the "Edit" page
  Then they should see "Edit Course Suggestion"
