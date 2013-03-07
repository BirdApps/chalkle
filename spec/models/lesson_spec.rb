require 'spec_helper'

describe Lesson do
  it { should have_many(:categories).through(:lesson_categories) }
  it { should have_one :lesson_image }

  it { should validate_uniqueness_of :meetup_id }
  it { should accept_nested_attributes_for :lesson_image }

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

  describe "cancellation email" do
    let(:lesson2) { FactoryGirl.create(:lesson, start_at: Date.today, min_attendee: 3) }

    it "sends cancellation email for too little bookings" do
      lesson2.class_may_cancel.should be_true
    end

    it "do not send cancellation email for sufficient bookings" do
      booking = FactoryGirl.create(:booking, lesson: lesson2, status: 'yes', guests: 5)
      lesson2.class_may_cancel.should be_false
    end
  end

  describe ".create_from_meetup_hash" do
    let(:result) { MeetupApiStub.lesson_response }
    let(:channel) { FactoryGirl.create(:channel) }

    it "saves valid lesson" do
      Lesson.create_from_meetup_hash(result, channel)
      Lesson.find_by_meetup_id(12345678).should be_valid
    end

    it "updates existing lesson" do
      FactoryGirl.create(:category, name: "music and dance")
      lesson = FactoryGirl.create(:lesson, meetup_id: 12345678, name: "cool class")
      Lesson.create_from_meetup_hash(result, channel)
      lesson.reload.name.should == "awesome class"
    end

    it "saves valid #meetup_data" do
      Lesson.create_from_meetup_hash(result, channel)
      lesson = Lesson.find_by_meetup_id 12345678
      lesson.meetup_data["id"].should == 12345678
      lesson.meetup_data["description"].should == "all about the class"
    end

    it "saves the correct RSVP limit" do
      Lesson.create_from_meetup_hash(result, channel)
      lesson = Lesson.find_by_meetup_id 12345678
      lesson.max_attendee.should == 10
    end

    it "set status to published" do
      Lesson.create_from_meetup_hash(result, channel)
      lesson = Lesson.find_by_meetup_id 12345678
      lesson.status.should == "Published"
    end

    it "set correct published date" do
      Lesson.create_from_meetup_hash(result, channel)
      lesson = Lesson.find_by_meetup_id 12345678
      lesson.published_at.to_time.to_i.should == 1351297791
    end

  end

  describe "#set_from_meetup_data" do
    let(:result) { MeetupApiStub::lesson_response }
    let(:channel) { FactoryGirl.create(:channel) }

    it "saves correct time values" do
      Lesson.create_from_meetup_hash(result, channel)
      lesson = Lesson.find_by_meetup_id 12345678
      lesson.created_at.to_time.to_i.should == 1351297791
      lesson.start_at.to_time.to_i.should == 1351297791
      lesson.duration.should == 600
    end
  end

  describe "#set_category" do
    it "should create an association" do
      category = FactoryGirl.create(:category, name: "category")
      lesson = FactoryGirl.create(:lesson)
      lesson.set_category 'category: a new lesson'
      lesson.categories.should include category
    end
  end

  describe "#set_name" do
    before do
      @lesson = Lesson.new
    end

    it "returns text after the colon" do
      @lesson.set_name('zzz: xxx').should == 'xxx'
    end

    it "strips whitespace from the lesson name" do
      @lesson.set_name(' xxx ').should == 'xxx'
    end
  end

end
