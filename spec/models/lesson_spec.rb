require 'spec_helper'

describe Lesson do
  it { should validate_uniqueness_of :meetup_id }

  let(:lesson) { FactoryGirl.create(:lesson) }

  describe ".visible" do
    it { Lesson.visible.should include(lesson) }

   	it "should not include hidden lesson" do
      lesson.visible = false
      lesson.save
      Lesson.visible.should_not include(lesson)
    end
  end

  describe ".hidden" do
    it "should include hidden lesson" do
      lesson.visible = false
      lesson.save
      Lesson.hidden.should include(lesson)
   	end

    it { Lesson.hidden.should_not include(lesson) }
  end
end
