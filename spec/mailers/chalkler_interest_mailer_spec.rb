require "spec_helper"

describe ChalklerInterestMailer do
  include EmailSpec::Helpers
  include EmailSpec::Matchers

  describe "Daily digest mail content" do
    let(:chalkler) { FactoryGirl.create(:chalkler) }
    let(:chalkler2) { FactoryGirl.create(:chalkler, email: "test@abc.com") }

    before do
      @lesson1 = FactoryGirl.create(:lesson, name: "Test Lesson 1", category_id: 1,start_at: Date.tomorrow, created_at: 1.day.ago)
      @lesson2 = FactoryGirl.create(:lesson, name: "Test Lesson 2", category_id: 2,start_at: Date.tomorrow, created_at: 1.week.ago)
      @lesson3 = FactoryGirl.create(:lesson, name: "Test Lesson 3", category_id: 3,start_at: Date.tomorrow, created_at: 1.day.ago)
      chalkler.email_categories = [1,3]
      chalkler2.email_frequency = [8]
      chalkler.email_frequency = "daily"
      chalkler2.email_frequency = "weekly"
      @email = ChalklerInterestMailer.digest(chalkler,chalkler.filtered_new_lessons,chalkler.filtered_still_open_lessons).deliver
      @email2 = ChalklerInterestMailer.digest(chalkler2,chalkler2.filtered_new_lessons,chalkler2.filtered_still_open_lessons).deliver
    end

    it "should deliver to the right person" do
      @email.should deliver_to(chalkler.email)
    end

    it "should have the right subject" do
      @email.should have_subject(chalkler.name + " - Here is your daily digest for " + Date.today().to_s)
    end

    it "should include lesson which is within chalkler's interest category" do
      @email.should have_body_text(@lesson1.name)
    end

    it "should not include lesson which not in chalkler's interest category" do
      @email.should_not have_body_text(@lesson2.name)
    end
  end

end
