require 'spec_helper'

describe Lesson do
  it { should validate_uniqueness_of :meetup_id }

  describe ".create_from_meetup_hash" do
    let(:result) { MeetupApiStub.lesson_response }
    let(:group) { FactoryGirl.create(:group) }

    it "saves valid lesson" do
      Lesson.create_from_meetup_hash(result, group)
      Lesson.find_by_meetup_id(12345678).should be_valid
    end

    it "updates existing lesson" do
      @lesson = FactoryGirl.create(:lesson, meetup_id: 12345678, name: "cool class")
      Lesson.create_from_meetup_hash(result, group)
      @lesson.reload.name.should == "awesome class"
    end
  end

  describe "#set_from_meetup_data" do
  end
end
