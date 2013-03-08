Feature: Chalkler
  In order to manage a chalkle channel
  Admins must be able to create, edit and update the chalkle membership database for that channel

  Scenario: Channel Admin can view form to new chalkler 
    Given I am logged in with the "channel admin" role
    When I visit the "Chalklers" page
    And I visit the "New Chalkler" page
    Then I should see the new chalkler form

  Scenario: A Channel Admin can create a new chalkler within the channels she manages
    Given I am logged in with the "channel admin" role with 5 channels
    When I visit the "Chalklers" page
    And I visit the "New Chalkler" page
    And I fill in the email of the chalkler
    And I select channels "Test Channel 1" and "Test Channel 2"
    And I click the "Create Chalkler" button
    Then a new chalkler is created in channels "Test Channel 1" and "Test Channel 2"

  Scenario: A single channel Channel Admin can create a new chalkler within her own channel
    Given I am logged in with the "channel admin" role with 1 channels
    When I visit the "Chalklers" page
    And I visit the "New Chalkler" page
    And I fill in the email of the chalkler
    And I click the "Create Chalkler" button
    Then a new chalkler is created in my channel