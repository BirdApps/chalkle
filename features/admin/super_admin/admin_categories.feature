Feature: Categories
  In order to manage chalkle
  Super Admin must be able to cluster all the different classes into a manageable number of categories

Background:
  Given "Jill" is a super admin
  And the admin "Jill" is authenticated

Scenario: A category with no details should render correctly
  Given there is a category with no details
  When they visit the "Categories" tab
  Then they should see this category
  And they visit the "View" page
  Then they should see this category

Scenario: A category with no details should be editable
  Given there is a category with no details
  When they visit the "Categories" tab
  And they visit the "Edit" page
  Then they should see "Edit Category"
