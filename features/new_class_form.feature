Feature: Teacher new class form
  In order for chalklers to suggest new classes
  They must be able to submit them to channel admins

Scenario: Chalkler can access New Class form
  Given the "Wellington" channel exists
  And I am logged in as a registered chalkler
  And I belong to the "Wellington" channel
  When I visit the "Teach" page
  Then I should see the New Class form

Scenario: Chalkler can submit a new class
  Given the "Wellington" channel exists
  And the "Science" category exists
  And I am logged in as a registered chalkler
  And I belong to the "Wellington" channel
  When I visit the "Teach" page
  And I enter Title as "new class"
  And I enter What we are doing as "learning new stuff"
  And I enter What will we learn as "that new stuff"
  And I select "Science" as the primary category
  And I click on the button "Submit my class"
  Then I should see the new class confirmation message
  And "Wellington" channel email link will be displayed

Scenario: Chalkler can select channel for class
  Given the "Wellington" channel exists
  And the "Whanau" channel exists
  And the "Science" category exists
  And I am logged in as a registered chalkler
  And I belong to the "Wellington" channel
  And I belong to the "Whanau" channel
  When I visit the "Teach" page
  And I enter Title as "new class"
  And I enter What we are doing as "learning new stuff"
  And I enter What will we learn as "that new stuff"
  And I select "Science" as the primary category
  And I select "Whanau" as the channel
  And I click on the button "Submit my class"
  Then I should see the new class confirmation message
  And "Whanau" channel email link will be displayed