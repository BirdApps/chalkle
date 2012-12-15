require 'spec_helper'

describe Lesson do
  it { should validate_uniqueness_of :meetup_id }

  describe ".show_visible_only" do
    context "show visible only should include visible lesson" do
      let(:lesson) { FactoryGirl.create(:lesson, visible: true) }
      it { Lesson.show_visible_only.should include(lesson) }
   	end

   	context "show visible only should not include invisible lesson" do
      let(:lesson) { FactoryGirl.create(:lesson, visible: false) }
      it { Lesson.show_visible_only.should_not include(lesson) }
  end

  describe ".show_invisible_only" do
    context "show invisible only should include invisible lesson" do
      let(:lesson) { FactoryGirl.create(:lesson, visible: false) }
      it { Lesson.show_invisible_only.should include(lesson) }
   	end

   	context "show invisible only should not include visible lesson" do
      let(:lesson) { FactoryGirl.create(:lesson, visible: true) }
      it { Lesson.show_invisible_only.should_not include(lesson) }
   	end
  end

end
