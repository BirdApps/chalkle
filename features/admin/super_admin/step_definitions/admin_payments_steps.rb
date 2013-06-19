Given /^there is an unreconciled payment with no details$/ do
  FactoryGirl.create(:payment, xero_id: "abc", total: 10)
end

Given /^there is a reconciled payment$/ do
  FactoryGirl.create(:payment, xero_id: "abc", total: 10, reconciled: true)
end

Then /^they should see this payment$/ do
  page.should have_content("10")
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
  page.should have_content("Payment #{payment.id} deleted!")
  payment.visible.should be_false
end

Given(/^there is an ureconciled payment$/) do
  FactoryGirl.create(:payment, xero_id: "abc", total: 10)
  chalkler = FactoryGirl.create(:chalkler, name: "Test chalkler")
  lesson = FactoryGirl.create(:lesson, name: "Test class", cost: 10, start_at: 1.day.from_now)
  FactoryGirl.create(:booking, chalkler_id: chalkler.id, lesson_id: lesson.id, status: "yes", guests: 0, paid: false)
end

When(/^they click to reconcile payments$/) do
  visit reconcile_admin_payments_path
end

Then(/^they select the matching booking from the drop down$/) do
  payment = Payment.find_by_xero_id "abc"
  option_xpath = "//*[@id='payment-#{payment.id}']/option[2]"
  second_option = find(:xpath, option_xpath).text
  chalkler = Chalkler.find_by_name "Test chalkler"
  b = Booking.find_by_chalkler_id chalkler.id  
  select("#{b.chalkler.name} - #{b.lesson.name}(#{b.lesson.meetup_id}) : #{b.lesson.start_at} : #{b.cost}", :from => "payment-#{payment.id}")
end

Then(/^this payment should be reconciled$/) do
  payment = Payment.find_by_xero_id "abc"
  payment.reconciled.should be_true
end
