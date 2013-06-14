Feature: Chalkler email setting form
  In order for chalklers to receive emailed class digests
  They must be able to change their email settings

Background:
  Given "Zac" is a chalkler
  And the chalkler "Zac" belongs to the "Wellington" channel
  And the chalkler "Zac" is authenticated
  When they visit the "Email settings" page

Scenario: Chalkler can change their email settings
  When they enter new email settings
  Then the chalkler "Zac" should have new email settings

Scenario: Chalkler can change their email categories and streams
  Given "business & finance" and "food & drink" are email categories
  Given "Royal Society Wellington Branch" is an email stream
  When they select new email categories and streams
  Then the chalkler "Zac" should have new category and stream settings