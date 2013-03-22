@omniauth_test
Feature: My Chalkle Login
  In order to use the site backend
  chalklers must be able to login

  Scenario: Meetup login without email skipping update
    Given A new meetup user
    When I am on the login page
    And I click "Sign in with Meetup"
    Then I should have a new Chalkle user with details from meetup
    Then I should see "don't have an email"
    When I click "Skip this step"
    Then I should see "Welcome"

  Scenario: Meetup login without email performing update
    Given A new meetup user
    When I am on the login page
    And I click "Sign in with Meetup"
    Then I should have a new Chalkle user with details from meetup
    Then I should see "don't have an email"
    When I fill in "chalkler_email" with "test@xxxx.com"
    Then I click "Update email"
    Then I should see "Welcome"

  Scenario: Meetup login > 1st time
    Given A existing meetup user
    When I am on the login page
    And I click "Sign in with Meetup"
    And I click "Sign out"
    And I click "Sign in with Meetup"
    Then I should have a existing Chalkle user with details from meetup
    Then I should see "Sign out"

