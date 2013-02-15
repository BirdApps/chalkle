require "spec_helper"

describe ChalklerInterestMailer do
  include EmailSpec::Helpers
  include EmailSpec::Matchers

  describe "Daily digest mail content" do
  	let(:lesson1) { FactoryGirl.create(:lesson, name: "Test Lesson 1", category_id: 1, start_at: 1.day.from_now) }
  	let(:lesson2) { FactoryGirl.create(:lesson, name: "Test Lesson 2", category_id: 2, start_at: 1.day.from_now) }
    let(:chalkler) { FactoryGirl.create(:chalkler) }

    before do
      chalkler.email_categories = [1,2]
      chalkler.email_frequency = "weekly"
      lesson1
      lesson2
      @email = ChalklerInterestMailer.digest(chalkler, Lesson.upcoming, Lesson.upcoming, chalkler.email_frequency).deliver
    end

    it "should deliver to the right person" do
      @email.should deliver_to(chalkler.email)
    end

    it "should have the right subject" do
      @email.should have_subject(chalkler.name + " - Here is your weekly digest for " + Date.today().to_s)
    end

    it "should include lesson within chalkler's interest category" do
      @email.should have_body_text(lesson1.name)
    end

    it "should not include lesson not in chalkler's interest category" do
      @email.should_not have_body_text(lesson2.name)
    end

  end
end
