require "spec_helper"

# I can be deleted, I just prove that js tests work ;-)
feature "Test feature", type: :feature, js: true do
  scenario "User can open the home page" do
    visit "/"
    expect(page).to have_text "FIND CLASSES NEAR YOU"
  end
end
