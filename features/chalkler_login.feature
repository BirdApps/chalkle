@omniauth_test
Feature: Chalkler Login
  In order to use my.chalkle.com chalklers must be able to create an account
  and log in.

Background:
  Given the "Horowhenua" channel exists

# Scenario: New chalkler logging in via Meetup will be created
  # Given "Amrit" is a new Meetup user
  # When they log in via Meetup
  # Then a new chalkler "Amrit" is created with details from Meetup

# Scenario: New chalkler logging in via Meetup is prompted for email address
  # Given "Jill" is a new Meetup user
  # When they log in via Meetup
  # Then they should see the Submit Email form
  # When they submit the Submit Email form
  # Then they should see the Dashboard
  # And the chalkler "Jill" has an updated email

Scenario: New chalkler can create an account
  When a new chalkler goes to the sign up page
  And they enter their details
  Then a new chalkler will be created

Scenario: Chalkler logging in via Meetup is updated from Meetup data
  Given "John" is an existing Meetup user
  When they log in via Meetup
  Then the chalkler "John" should be updated

Scenario: Chalkler with no channels will be blocked
  Given "Mohammed" is a chalkler
  And the chalkler "Mohammed" doesn't belong to a channel
  And the chalkler "Mohammed" is authenticated
  Then they will be redirected to an error page
