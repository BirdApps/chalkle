require 'spec_helper'

describe Lesson do
  it { should belong_to(:course)}

  specify { FactoryGirl.create(:lesson).should be_valid }

  let(:lesson) { FactoryGirl.create(:lesson) }


  describe "start_at" do
    it "should be within 100 years either side of now" do
      lesson.start_at = 101.years.ago.to_date
      lesson.should_not be_valid
      lesson.start_at = 101.years.from_now.to_date
      lesson.should_not be_valid
      lesson.start_at = Time.now.to_date
      lesson.should be_valid
    end
  end

  describe "duration" do
    it "should be a positive float" do
      lesson.duration = -1.5
      lesson.should_not be_valid
      lesson.duration = 1.5
      lesson.should be_valid
    end
  end

end
