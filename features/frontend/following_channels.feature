Feature: Following channels
	In order for chalklers to keep up with classes they might like
	They want to follow a channel

  Background:
    Given "Quinn" is a chalkler
    And the chalkler "Quinn" is authenticated
    And the "Enspiral" channel exists

  @javascript
  Scenario: Chalkler follows and unfollows a channel
    Given they visit the "Enspiral" channel page
    When they follow the channel
    Then they should see the option to unfollow the channel
    When they unfollow the channel
    Then they should see the option to follow the channel
