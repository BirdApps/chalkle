Feature: Lessons
  In order to administer a chalkle channel
  Channel Admin must be able to bring to life all different classes that chalklers want

Background:
  Given "Joy" is a channel admin
  And the admin "Joy" belongs to the "Wellington" channel
  And the admin "Joy" is authenticated

Scenario: A lesson with no details should render correctly
  Given there is a lesson with no details in the "Wellington" channel
  When they visit the "Lessons" tab
  Then they should see this lesson in the "Wellington" channel
  And they visit the "View" page
  Then they should see this lesson in the "Wellington" channel

Scenario: Channel admin can not see a lesson from another channel
  Given the "Dunedin" channel exists
  And there is a lesson with no details in the "Dunedin" channel
  When they visit the "Lessons" tab
  Then they should not see this lesson 

Scenario: A lesson with no details should be editable
  Given there is a lesson with no details in the "Wellington" channel
  When they visit the "Lessons" tab
  And they visit the "Edit" page
  Then they should see "Edit Lesson"

Scenario: Channel admins can copy a lesson in their own channel
  Given there is a lesson with no details in the "Wellington" channel
  When they visit the "Lessons" tab
  And they visit the "View" page
  And they click on the "Copy Lesson" button
  Then they should produce a copy of this lesson

Scenario: Channel admins can delete a lesson from their own channel
  Given there is a lesson with no details in the "Wellington" channel
  When they visit the "Lessons" tab
  And they visit the "View" page
  And they press the "Delete Lesson" button
  Then this lesson should be deleted

@javascript
Scenario: Given a teacher cost, channel admins can see the advertised price for a class by editing the class details
  Given there is a lesson with no details in the "Wellington" channel
  And the "Wellington" channel has a teacher percentage of "70" percent
  And the "Wellington" channel has a channel percentage of "10" percent 
  When they visit the "Lessons" tab
  And they visit the "Edit" page
  And they fill in a teacher fee of "20"
  Then they should see an advertised price of "30"

