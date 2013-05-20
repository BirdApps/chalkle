Feature: Chalklers
  In order to administer chalkle
  Admin must be able to create, modify and query all the chalkle members (aka chalklers)

Background:
  Given "Jill" is a super admin
  And the admin "Jill" is authenticated

Scenario: A chalkler with no details should render correctly
  Given there is a chalkler with no details
  When they visit the "Chalklers" page
  Then they should see this chalkler


