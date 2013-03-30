Feature: Chalkler email setting form
  In order for chalklers to receive emailed class digests
  They must be able to change their email settings

Scenario: Chalkler can access email setting form
  Given I am logged in as a registered chalkler
  When I visit the "Email Settings" page
  Then I should see the email settings form

Scenario: Chalkler can submit email setting form
  Given I am logged in as a registered chalkler
  When I visit the "Email Settings" page
  And I click on the button "Save Email Preferences"
  Then I should see the email settings confirmation message

Scenario: Chalkler can change their email address
  Given I am logged in as a registered chalkler
  When I visit the "Email Settings" page
  And I type in my email as "new@chalkle.com"
  And I click on the button "Save Email Preferences"
  Then my email should be "new@chalkle.com"

Scenario: Form is prepoulated with chalkler's existing email address
  Given I am logged in as a registered chalkler
  And my registered email is "test@chalkle.com"
  When I visit the "Email Settings" page
  Then the email "test@chalkle.com" should be displayed

Scenario: Chalkler can change their email frequency
  Given I am logged in as a registered chalkler
  When I visit the "Email Settings" page
  And I select "Daily" as my email frequency
  And I click on the button "Save Email Preferences"
  Then my email frequency should be "daily"

Scenario: Form is prepopulated with chalkler's existing email frequency
  Given I am logged in as a registered chalkler
  And I had selected "daily" as my email frequency
  When I visit the "Email Settings" page
  Then the email frequency "daily" should be displayed

Scenario: Chalkler can change their email category
  Given "businesses and finances" and "food & drink" are email categories
  And I am logged in as a registered chalkler
  When I visit the "Email Settings" page
  And I select "businesses and finances" and "food & drink" as my email categories
  And I click on the button "Save Email Preferences"
  Then my email categories should be "businesses and finances" and "food & drink"

Scenario: Form is prepopulated with chalkler's existing categories
  Given "businesses and finances" and "food & drink" are email categories
  And I am logged in as a registered chalkler
  And I had set my email categories to "businesses and finances" and "food & drink"
  When I visit the "Email Settings" page
  Then the email categories "businesses and finances" and "food & drink" should be checked

Scenario: Chalkler can change their email streams
  Given "Royal Society Wellington Branch" is an email stream
  And I am logged in as a registered chalkler
  When I visit the "Email Settings" page
  And I select "Royal Society Wellington Branch" as my email stream
  And I click on the button "Save Email Preferences"
  Then my stream should be "Royal Society Wellington Branch"

Scenario: Form is prepopulated with chalkler's existing streams
  Given "Royal Society Wellington Branch" is an email stream
  And I am logged in as a registered chalkler
  And I had set my stream to "Royal Society Wellington Branch"
  When I visit the "Email Settings" page
  Then the email stream "Royal Society Wellington Branch" should be checked