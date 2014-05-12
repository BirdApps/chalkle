@omniauth_test
Feature: Chalkler Deletes Account
  In order to use chalkle.com chalklers must be able to delete their account


Background:
  Given "Jill" is a chalkler
  And the chalkler "Jill" is authenticated

  # Scenario: chalkler can delete account
  #   When they press the "Delete account permenantly" button
  #   Then the chalkler "Jill" is deleted