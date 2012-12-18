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
      lesson = FactoryGirl.create(:lesson, meetup_id: 12345678, name: "cool class")
      Lesson.create_from_meetup_hash(result, group)
      lesson.reload.name.should == "music and dance: awesome class"
    end

    it "saves valid #meetup_data" do
      Lesson.create_from_meetup_hash(result, group)
      lesson = Lesson.find_by_meetup_id 12345678
      lesson.meetup_data["id"].should == 12345678
      lesson.meetup_data["description"].should == "all about the class"
    end
  end

  describe "#set_from_meetup_data" do
    let(:result) { MeetupApiStub::lesson_response }
    let(:group) { FactoryGirl.create(:group) }

    it "saves correct time values" do
      Lesson.create_from_meetup_hash(result, group)
      lesson = Lesson.find_by_meetup_id 12345678
      lesson.created_at.to_time.to_i.should == 1351297791
      lesson.updated_at.to_time.to_i.should == 1351297791
      lesson.start_at.to_time.to_i.should == 1351297791
      lesson.duration.should == 600
    end

    it "associates with existing category" do
      category = FactoryGirl.create(:category, name: "music and dance")
      Lesson.create_from_meetup_hash(result, group)
      lesson = Lesson.find_by_meetup_id 12345678
      lesson.category_id.should == category.id
    end

    it "creates new category where none exists" do
      Lesson.create_from_meetup_hash(result, group)
      Category.find_by_name("music and dance").should be_valid
    end
  end
end
