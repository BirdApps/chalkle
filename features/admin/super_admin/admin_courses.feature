Feature: Courses
  In order to administer chalkle
  Super Admin must be able to record transactions for each class and query classes across all chalkle channels

Background:
  Given "Jill" is a super admin
  And the admin "Jill" is authenticated

Scenario: A course with no details should render correctly
  Given there is a course with no details
  When they visit the "Courses" tab
  And they visit the "Unpublished" page
  Then they should see this course
  And they visit the "View" page
  Then they should see this course

Scenario: A course with no details should be editable
  Given there is a course with no details
  When they visit the "Courses" tab
  And they visit the "Unpublished" tab
  And they visit the "Edit" page
  Then they should see "Edit Course"

Scenario: Super admin can access payment summary for a paid course in the past 
  Given there is a paid course in the past
  When they click into this course
  And they press the "Payment email" button
  Then they should see the payment summary
