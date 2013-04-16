@omniauth_test
Feature: My Chalkle Login
  In order to use the site backend
  chalklers must be able to login

Scenario: Meetup login without email performing update
  Given "Jill" is a new meetup user
  And They are on the login page
  When They click "Sign in with Meetup"
  Then They should have a new Chalkle user with details from meetup
  Then They should see "Almost there!"
  When They fill in "chalkler_email" with "test@xxxx.com"
  Then They click "Submit email"
  Then They should see "Welcome"

Scenario: Meetup login > 1st time
  Given "John" is a existing meetup user
  And They are on the login page
  When They are on the login page
  And They click "Sign in with Meetup"
  And They click "Sign out"
  And They click "Sign in with Meetup"
  Then They should have a existing Chalkle user with details from meetup
  Then They should see "Sign out"

