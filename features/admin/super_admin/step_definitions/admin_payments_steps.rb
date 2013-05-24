Given /^there is an unreconciled payment with no details$/ do
  FactoryGirl.create(:payment, xero_id: "abc", total: 10)
end

Then /^they should see this payment$/ do
  page.should have_content("10")
end
