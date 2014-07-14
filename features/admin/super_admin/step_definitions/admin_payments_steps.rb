Given /^there is an unreconciled payment with no details$/ do
  FactoryGirl.create(:payment, xero_id: "abc", total: 10)
end

Given /^there is a reconciled payment$/ do
  FactoryGirl.create(:payment, xero_id: "abc", total: 10, reconciled: true)
end

Then /^they to see this payment$/ do
  expect(page).to have_content("10")
end

And(/^they click into this payment$/) do 
  click_link "Payments"
  click_link "View"
end

And(/^they fill in the comments with "(.*?)"$/) do |comments|
  fill_in 'active_admin_comment_body', with: comments
  click_button 'Add Comment'
end

When(/^they return to the payment index page$/) do
  visit admin_payments_path
end

Then /^this payment should be deleted$/ do
  payment = Payment.find_by_xero_id("abc")
  expect(page).to have_content("Payment #{payment.id} deleted!")
  expect(payment.visible).to be false
end

Given(/^there is an ureconciled payment$/) do
  FactoryGirl.create(:payment, xero_id: "abc", total: 10)
  chalkler = FactoryGirl.create(:chalkler, name: "Test chalkler")
  teacher = FactoryGirl.create(:chalkler, name: "Test teacher")
  lesson = FactoryGirl.create(:lesson, start_at: 1.day.from_now, duration: 1)
  course = FactoryGirl.create(:course, name: "Test class", cost: 10, lessons: [lesson], teacher_id: teacher.id)
#  chalkler.channels << FactoryGirl.create(:channel)
#  course.channel = chalkler.channels.first
  FactoryGirl.create(:booking, chalkler_id: chalkler.id, course_id: course.id, status: "yes", guests: 0, paid: false)
end

When(/^they click to reconcile payments$/) do
  visit reconcile_admin_payments_path
end

Then(/^they select the matching booking from the drop down$/) do
  payment = Payment.find_by_xero_id "abc"
  option_xpath = "//select[@id='payment-#{payment.id}']/option[2]"
  option = find(:xpath, option_xpath).text
  select(option, :from => "payment-#{payment.id}")
  click_button 'Reconcile'
end

Then(/^this payment should be reconciled$/) do
  payment = Payment.find_by_xero_id "abc"
  expect(payment.reconciled).to be true
end
