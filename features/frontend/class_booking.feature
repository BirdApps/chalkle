Feature: Class Listing
In order to decide which class to join, chalkler must be able to view classes

Background:
Given "Said" is a chalkler
And the chalkler "Said" belongs to the "Horowhenua" channel
And the chalkler "Said" is authenticated
And there is a class "Test class" open to sign-up

Scenario: Chalkler can see the class being listed
When they visit the class listings
Then they should see "Test class"

Scenario: Chalkler can see pictures attached to a class
Given the class "Test class" has an image
When they visit the class listings
Then they should see this image

