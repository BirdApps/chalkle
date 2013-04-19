@omniauth_test
Feature: Chalkler Login
  In order to use my.chalkle.com chalklers must be able to log in.

Scenario: New chalkler logging in via Meetup will be created
  Given "Amrit" is a new Meetup user
  When they log in via Meetup
  Then a new chalkler "Amrit" is created with details from Meetup

Scenario: New chalkler logging in via Meetup is prompted for email address
  Given "Jill" is a new Meetup user
  When they log in via Meetup
  Then they should see the Submit Email form
  When they submit the Submit Email form
  Then they should see the Dashboard
  And the chalkler "Jill" has an updated email

Scenario: Chalkler logging in via Meetup is updated from Meetup data
  Given "John" is an existing Meetup user
  When they log in via Meetup
  Then the chalkler "John" should be updated
