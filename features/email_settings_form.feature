Feature: Chalkler email setting form
  In order for chalklers to receive emailed class digests
  They must be able to change their email settings

Background:
  Given "Zac" is a chalkler
  And the chalkler "Zac" is authenticated

Scenario: Chalkler can change their email address
  When they visit the Email Settings page
  And they enter a new email address
  Then the chalkler "Zac" should have a new email address

Scenario: Form contains chalkler's existing email address
  When they visit the Email Settings page
  Then the email "zac@chalkle.com" should be displayed

Scenario: Chalkler can change their email frequency
  When they visit the Email Settings page
  And they change their email frequency to "Daily"
  Then the chalkler "Zac" should have a "daily" email frequency

Scenario: Form contains chalkler's existing email frequency
  Given I had selected "daily" as my email frequency
  When they visit the Email Settings page
  Then the email frequency "daily" should be displayed

Scenario: Chalkler can change their email category
  Given "businesses and finances" and "food & drink" are email categories
  When they visit the Email Settings page
  And I select "businesses and finances" and "food & drink" as my email categories
  And I click on the button "Save Email Preferences"
  Then my email categories should be "businesses and finances" and "food & drink"

Scenario: Form is prepopulated with chalkler's existing categories
  Given "businesses and finances" and "food & drink" are email categories
  And I had set my email categories to "businesses and finances" and "food & drink"
  When they visit the Email Settings page
  Then the email categories "businesses and finances" and "food & drink" should be checked

Scenario: Chalkler can change their email streams
  Given "Royal Society Wellington Branch" is an email stream
  When they visit the Email Settings page
  And I select "Royal Society Wellington Branch" as my email stream
  And I click on the button "Save Email Preferences"
  Then my stream should be "Royal Society Wellington Branch"

Scenario: Form is prepopulated with chalkler's existing streams
  Given "Royal Society Wellington Branch" is an email stream
  And I had set my stream to "Royal Society Wellington Branch"
  When they visit the Email Settings page
  Then the email stream "Royal Society Wellington Branch" should be checked