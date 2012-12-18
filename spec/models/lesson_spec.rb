require 'spec_helper'

describe Lesson do
  it { should validate_uniqueness_of :meetup_id }

  describe ".visible" do
    it "should include visible lesson" do
      lesson = FactoryGirl.create(:lesson, visible: true) 
      Lesson.visible.should include(lesson) 
   	end

   	it "should not include hidden lesson" do
      lesson = FactoryGirl.create(:lesson, visible: false) 
      Lesson.visible.should_not include(lesson)
    end
  end

  describe ".hidden" do
   it "should include hidden lesson" do
      lesson = FactoryGirl.create(:lesson, visible: false) 
      Lesson.hidden.should include(lesson)
   	end

   	it "should not include visible lesson" do
      lesson = FactoryGirl.create(:lesson, visible: true) 
      Lesson.hidden.should_not include(lesson)
   	end
  end

end
