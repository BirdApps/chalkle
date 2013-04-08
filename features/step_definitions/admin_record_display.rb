Given /^I am logged in with the "(.*?)" role$/ do |role|
  AdminUser.create(email: "test@chalkle.com", password: 'password', role: role)
  visit '/admin/login'
  fill_in "admin_user_email", :with => "test@chalkle.com"
  fill_in "admin_user_password", :with => "password"
  click_button "Login"
end

Given /^there is an unreconciled payments with no details$/ do
  @payment = Payment.create(xero_id: "abc", total: 10)
end

When /^I visit the "(.*?)" page$/ do |link|
  click_link link
end

Then /^I should still see this payment$/ do
  page.should have_content("#{@payment.total}")
end

Given /^there is a lesson with no details$/ do
  @lesson = Lesson.create(name: "test class")
end

Then /^I should still see this lesson$/ do
  page.should have_content("#{@lesson.name}")
end

Given /^there is a channel with no details$/ do
  @channel = Channel.create(name: "test channel", url_name: "blah")
end

Then /^I should still see this channel$/ do
  page.should have_content("#{@channel.name}")
  page.should have_content("#{@channel.url_name}")
end

Given /^there is a chalkler with no details$/ do
   @chalkler = Chalkler.create()
end

Then /^I should still see this chalkler$/ do
  page.should have_content("#{@chalkler.id}")
end

Given /^there is a category with no details$/ do
  @category = Category.create(name: "test category")
end

Then /^I should still see this category$/ do
  page.should have_content("#{@category.name}")
end

Given /^there is a booking with no details$/ do
  @lesson = Lesson.create(name: "test class")
  @chalkler = Chalkler.create()
  @booking = Booking.create(lesson_id: @lesson.id, chalkler_id: @chalkler.id)
end

Then /^I should still see this booking$/ do
  page.should have_content("#{@lesson.name}")
end

Given /^there is an admin user with no details$/ do
  @admin = AdminUser.create(email: "test@chalkle.com")
end

Then /^I should still see this admin user$/ do
  page.should have_content("#{@admin.email}")
end

