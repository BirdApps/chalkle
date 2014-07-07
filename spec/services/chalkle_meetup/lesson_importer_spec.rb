require 'spec_helper'
require 'chalkle_meetup/course_importer'

describe ChalkleMeetup::CourseImporter do
  describe ".import" do
    let(:result) { MeetupApiStub.course_response }
    let(:channel) { FactoryGirl.create(:channel) }

    it "saves valid course" do
      course = subject.import(result, channel)
      Course.find_by_meetup_id(12345678).should be_valid
    end

    it "updates existing course" do
      FactoryGirl.create(:category, name: "music and dance")
      course = FactoryGirl.create(:course, meetup_id: 12345678, name: "cool class")
      subject.import(result, channel)
      course.reload.name.should == "awesome class"
    end

    it "saves valid #meetup_data" do
      course = subject.import(result, channel)
      course.meetup_data["id"].should == 12345678
      course.meetup_data["description"].should == "all about the class"
    end

    it "saves the correct RSVP limit" do
      course = subject.import(result, channel)
      course.max_attendee.should == 10
    end

    it "set status to published" do
      course = subject.import(result, channel)
      course.status.should == "Published"
    end

    it "set correct published date" do
      course = subject.import(result, channel)
      course.published_at.to_time.to_i.should == 1351297791
    end

    it "update published date for a course already created" do
      course = FactoryGirl.create(:course, meetup_id: 12345678, start_at: Date.today)
      subject.import(result, channel)
      course.reload.published_at.to_time.to_i.should == 1351297791
    end

    it "update start_at time" do
      course = subject.import(result, channel)
      course.start_at = Date.today()
      course.save!
      subject.import(result, channel)
      course.reload.start_at.to_time.to_i.should == 1351297791
    end
  end
end
