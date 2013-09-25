require 'spec_helper'
require 'chalkle_meetup/lesson_importer'

describe ChalkleMeetup::LessonImporter do
  describe ".create_from_meetup_hash" do
    let(:result) { MeetupApiStub.lesson_response }
    let(:channel) { FactoryGirl.create(:channel) }

    it "saves valid lesson" do
      lesson = subject.import(result, channel)
      Lesson.find_by_meetup_id(12345678).should be_valid
    end

    it "updates existing lesson" do
      FactoryGirl.create(:category, name: "music and dance")
      lesson = FactoryGirl.create(:lesson, meetup_id: 12345678, name: "cool class")
      subject.import(result, channel)
      lesson.reload.name.should == "awesome class"
    end

    it "saves valid #meetup_data" do
      lesson = subject.import(result, channel)
      lesson.meetup_data["id"].should == 12345678
      lesson.meetup_data["description"].should == "all about the class"
    end

    it "saves the correct RSVP limit" do
      lesson = subject.import(result, channel)
      lesson.max_attendee.should == 10
    end

    it "set status to published" do
      lesson = subject.import(result, channel)
      lesson.status.should == "Published"
    end

    it "set correct published date" do
      lesson = subject.import(result, channel)
      lesson.published_at.to_time.to_i.should == 1351297791
    end

    it "update published date for a lesson already created" do
      lesson = FactoryGirl.create(:lesson, meetup_id: 12345678, start_at: Date.today)
      subject.import(result, channel)
      lesson.reload.published_at.to_time.to_i.should == 1351297791
    end

    it "update start_at time" do
      lesson = subject.import(result, channel)
      lesson.start_at = Date.today()
      lesson.save!
      subject.import(result, channel)
      lesson.reload.start_at.to_time.to_i.should == 1351297791
    end
  end
end
