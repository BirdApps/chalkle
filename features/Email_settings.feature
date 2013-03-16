Feature: Chalkler email setting form
  In order for chalklers to hear about classes
  They must be able to change their email settings

Scenario: Chalkler can access email setting form
  Given I am logged in as a registered chalkler
  When I visit the "Email Settings" page
  Then I should see the email setting form

Scenario: Chalkler can submit email setting form
  Given I am logged in as a registered chalkler
  When I visit the "Email Settings" page
  And I click on the button "Save Email Preferences"
  Then I should see the confirmation message

Scenario: Chalkler can change their email address
  Given I am logged in as a registered chalkler
  When I visit the "Email Settings" page
  And I type in my email as "new@chalkle.com"
  And I click on the button "Save Email Preferences"
  Then I should see the confirmation message
  And my email should be saved

Scenario: Form load with chalkler's existing email address
  Given I am logged in as a registered chalkler
  And my registered email is "test@chalkle.com"
  When I visit the "Email Settings" page
  Then the email "test@chalkle.com" should be displayed

Scenario: Chalkler can change their email frequency
  Given I am logged in as a registered chalkler
  When I visit the "Email Settings" page
  And I select "daily" as my email frequency
  Then my email frequency should be "daily"

Scenario: Form load with chalkler's existing email frequency
  Given I am logged in as a registered chalkler
  And I had selected "daily" as my email frequency
  When I visit the "Email Settings" page
  Then the email frequency "daily" should be displayed

Scenario: Chalkler can change their email category
  Given "businesses and finances" and "food & drink" are email categories
  And I am logged in as a registered chalkler
  When I visit the "Email Settings" page
  And I select "businesses and finances" as my email category
  And I select "food & drink" as my email category
  Then my email category should be saved

Scenario: Form load with chalkler's existing categories
  Given I am logged in as a registered chalkler
  And "food & drink" is an email category
  And I had set my category to "food & drink"
  When I visit the "Email Settings" page
  Then the email category "food & drink" should be checked

Scenario: Chalkler can change their email streams
  Given I am logged in as a registered chalkler
  And "Royal Society Wellington Branch" is an email stream
  When I visit the "Email Settings" page
  And I select "Royal Society Wellington Branch" as my email stream
  Then my stream should be saved

Scenario: Form load with chalkler's existing streams
  Given I am logged in as a registered chalkler
  And "Royal Society Wellington Branch" is an email stream
  And I had set my stream to "Royal Society Wellington Branch"
  When I visit the "Email Settings" page
  Then the email stream "Royal Society Wellington Branch" should be checked


