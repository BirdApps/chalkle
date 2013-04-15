require 'spec_helper'

describe LessonDecorator do
  let(:lesson) { FactoryGirl.create(:lesson).decorate }

  describe ".category_list" do
    it "returns nil when a lesson has no categories" do
      lesson.category_list.should be_nil
    end

    it "returns a formated list of categories" do
      ['one', 'two', 'three'].each do |c|
        lesson.categories << FactoryGirl.create(:category, name: c)
      end
      lesson.category_list.should == 'In One, Two, Three'
    end
  end

  describe ".join_chalklers" do
    it "returns generic text when attendence is less than 2" do
      FactoryGirl.create(:booking, status: 'yes', guests: 0, lesson: lesson)
      lesson.join_chalklers.should == 'Join this chalkle'
    end

    it "formats text when attendence is more than 1" do
      2.times { FactoryGirl.create(:booking, status: 'yes', guests: 0, lesson: lesson) }
      lesson.join_chalklers.should == 'Join 2 other chalklers'
    end
  end


end
