Given /^there is an unreconciled payment with no details$/ do
  FactoryGirl.create(:payment, xero_id: "abc", total: 10)
end

Then /^they should see this payment$/ do
  page.should have_content("10")
end

Then /^this payment should be deleted$/ do
  payment = Payment.last
  page.should have_content("Payment #{payment.id} deleted!")
  payment.visible.should be_false
end
