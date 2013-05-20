Feature: Categories
  In order to administer chalkle
  Admin must be able to create, modify and query different ways to categorise classes

Background:
  Given "Jill" is a super admin
  And the admin "Jill" is authenticated

Scenario: A categories with no details should render correctly
  Given there is a category with no details
  When they visit the "Categories" page
  Then they should see this category


