Feature: Following channels
	In order for chalkders to keep up with classes they might like
	They want to follow a channel

Background:
	Given "Quinn" is a chackler
	And the chalker "Quinn" is authenticated
	And "Enspiral" is a channel

Scenario: Chalkler follows a channel
	Given the chalker visits the Enspiral channel page
	When the chalker chooses to follow the channel
	Then the chalker should see the option to unfollow the channel
