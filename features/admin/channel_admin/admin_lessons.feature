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
  When they click on the "Update Lesson" button
  Then they should see "Lesson was successfully updated"

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

Scenario: Channel admin can see attendee list for each lesson
  Given there is a lesson with no details in the "Wellington" channel
  And this lesson has one paid booking by a chalkler named "Bob"
  When they view this lesson
  Then they should see a paid booking by "Bob"

Scenario: Channel admin can record cash payment for attendees
  Given there is a lesson with no details in the "Wellington" channel
  And this lesson has one paid booking by a chalkler named "Bob"
  When they view this lesson
  And they press the "Pay $20.00" button
  Then this booking should be paid

Scenario: Comments on unreviewed lessons are displayed on the dashboard
  Given there is an unreviewed lesson with no details in the "Wellington" channel
  When they view this lesson
  And they fill in the lessons comments with "This is a comment"
  When they visit the "Dashboard" tab
  Then they should see "This is a comment"

Scenario: Channel admin can see warning when the teacher is not assigned
  Given there is a lesson with no details in the "Wellington" channel
  When they view this lesson
  Then they should see "Please Select A Teacher"

Scenario: Channel admin can see the teacher's email
  Given "Alice" is a chalkler
  And the chalkler "Alice" belongs to the "Wellington" channel
  And "Alice" is teaching a lesson
  When they view this lesson
  Then they should see "alice@chalkle.com"

Scenario: Channel admin can see warning when teacher has no email
  Given "Alice" is a chalkler
  And the chalkler "Alice" belongs to the "Wellington" channel
  And the chalkler "Alice" has no email
  And "Alice" is teaching a lesson
  When they view this lesson
  Then they should see "Please Click On Teacher Above And Enter Their Email"

Scenario: Channel admin can see warning when lesson has no date/time
  Given there is a lesson with no date in the "Wellington" channel
  When they view this lesson
  Then they should see "This Class Must Have A Date And Time"

Scenario: Channel admin can see warning when lesson has no synopsis
  Given there is a lesson with no what we will do text in the "Wellington" channel
  When they view this lesson
  Then they should see "This Class Must Have A What We Will Do During The Class"

Scenario: Channel admin can see warning when lesson has no teacher cost
  Given there is a lesson with no teacher cost in the "Wellington" channel
  When they view this lesson
  Then they should see "This Class Must Have A Teacher Cost"

Scenario: Channel admin can see warning when lesson has no venue cost
  Given there is a lesson with no venue cost in the "Wellington" channel
  When they view this lesson
  Then they should see "This Class Must Have A Venue Cost"

Scenario: Channel admin can see warning when RSVP number is below minimum attendees required
  Given there is a lesson in the "Wellington" channel with RSVP numbers below the minimum number of attendees
  When they view this lesson
  Then they should see "Lower This Number If The Class Is Still Going Ahead"

Scenario: Upload an image for the class
  Given there is a lesson with no details in the "Wellington" channel
  When they edit this lesson
  And they attach an image to the lesson
  Then this image should be saved
  When they visit the "Wellington" channel class listing
  Then they should see this image on the class listing
