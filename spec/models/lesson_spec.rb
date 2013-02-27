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

    it "set lesson to published" do
      Lesson.create_from_meetup_hash(result, channel)
      lesson = Lesson.find_by_meetup_id 12345678
      lesson.status.should == "Published"
    end
  end

  describe "#set_category" do
    before do
      @category = FactoryGirl.create(:category, name: "category1")
      @lesson = FactoryGirl.create(:lesson, name: "category1: a new lesson")
      @lesson.set_category
    end

    it "should create a new category from lesson title" do
      Category.find_by_name("category1").valid?.should be_true
    end

    it "should strip whitespace from the lesson name" do
      @lesson.name.should == 'a new lesson'
    end

    it "should create an association" do
      @lesson.categories.should include @category
    end
  end

  describe "class costs" do

    let(:lesson) { FactoryGirl.create(:lesson) }
    
    describe "default values" do
      
      it "should set default channel cost" do
        lesson.channel_cost.should == 0.0
      end

    end
  
  end

end
