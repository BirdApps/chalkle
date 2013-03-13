require 'spec_helper'

describe Lesson do
  it { should have_many(:categories).through(:lesson_categories) }
  it { should have_one :lesson_image }

  it { should validate_uniqueness_of :meetup_id }
  it { should accept_nested_attributes_for :lesson_image }

  let(:lesson) { FactoryGirl.create(:lesson) }

  describe "column validations" do

    it "should not allow non valid status" do
      lesson.status = "resres"
      lesson.should_not be_valid
    end

  end

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

  describe "material cost validation" do
    before do
      @lesson = FactoryGirl.create(:lesson)
    end
    it "assigns default material cost" do
      @lesson.material_cost.should == 0
    end

    it "does not allow non numerical costs" do 
      @lesson.material_cost = "rewrew"
      @lesson.should_not be_valid
    end

  describe "lesson costs" do

    let(:result) { MeetupApiStub::lesson_response }
    let(:channel) { FactoryGirl.create(:channel, channel_percentage: 0.2, teacher_percentage: 0.5) }
    
    before do
      Lesson.create_from_meetup_hash(result, channel)
      @lesson = Lesson.find_by_meetup_id 12345678
      @lesson.cost = 20
      @lesson.save
    end
    
    describe "cost validations" do
      it "should not allow non numercial teacher cost" do
        @lesson.teacher_cost = "resres"
        @lesson.should_not be_valid
      end

      it "should not allow non numercial cost" do
        @lesson.cost = "resres"
        @lesson.should_not be_valid
      end

      it "should not allow negative cost" do
        @lesson.cost = -10
        @lesson.should_not be_valid
      end

      it "should not allow non numerical teacher payment" do
        @lesson.teacher_payment = "resres"
        @lesson.should_not be_valid
      end

      it "should not allow teacher cost greater than cost" do
        @lesson.teacher_cost = 40
        @lesson.should_not be_valid
      end

    end

    describe "default values" do

      it "should retrieve the channel's channel percentage" do
        @lesson.channel_percentage.should == channel.channel_percentage
      end

      it "should retrieve the channel's chalkle percentage" do
        @lesson.chalkle_percentage.should == channel.chalkle_percentage
      end

      it "should use default chalkle percentage if there are no channels" do
        lesson2 = FactoryGirl.create(:lesson, meetup_id: 516473924)
        lesson2.chalkle_percentage.should == 0.125
      end

      it "should use default channel percentage if there are no channels" do
        lesson2 = FactoryGirl.create(:lesson, meetup_id: 516473924)
        lesson2.channel_percentage.should == 0.125
      end

    end

    describe "override exists" do

      it "should override the default channel percentage" do
        @lesson.channel_percentage_override = 0.0
        @lesson.save
        @lesson.channel_percentage.should == 0.0
      end

      it "should not allow non numerical channel percentage override" do
        @lesson.channel_percentage_override = "resres"
        @lesson.should_not be_valid
      end

      it "should not allow channel percentage override greater than 1" do
        @lesson.channel_percentage_override = 1.2
        @lesson.should_not be_valid
      end

      it "should not allow channel percentage that exceeds 1 - chalkle percentage" do
        @lesson.channel_percentage_override = 1 - @lesson.chalkle_percentage + 0.1
        @lesson.save
        @lesson.should_not be_valid
      end

      it "should override the default chalkle percentage" do
        @lesson.chalkle_percentage_override = 0.5
        @lesson.save
        @lesson.chalkle_percentage.should == 0.5
      end

      it "should not allow non numerical chalkle percentage override" do
        @lesson.chalkle_percentage_override = "resres"
        @lesson.should_not be_valid
      end

      it "should not allow chalkle percentage override greater than 1" do
        @lesson.chalkle_percentage_override = 1.2
        @lesson.should_not be_valid
      end

      it "should not allow sum of teacher cost, channel cost and chalkle cost that differs from cost by more than 50 cents" do
        @lesson.cost = 20;
        @lesson.teacher_cost = 10;
        @lesson.chalkle_percentage_override = 0.2
        @lesson.channel_percentage_override = 0.6
        @lesson.should_not be_valid
      end

      it "should allow sum of teacher cost, channel cost and chalkle cost that differs from cost by less than 50 cents" do
        @lesson.cost = 24;
        @lesson.teacher_cost = 11.76;
        @lesson.chalkle_percentage_override = 0.2
        @lesson.channel_percentage_override = 0.3
        @lesson.should be_valid
      end

      it "when teacher cost is 0, should not allow sum of chalkle and channel percentage not equal 1" do
        @lesson.cost = 20;
        @lesson.teacher_cost = 0;
        @lesson.chalkle_percentage_override = 0.2
        @lesson.channel_percentage_override = 0.3
        @lesson.should_not be_valid
      end

      it "when teacher cost is 0, should allow sum of chalkle and channel percentage equal 1" do
        @lesson.cost = 20;
        @lesson.teacher_cost = 0;
        @lesson.chalkle_percentage_override = 0.7
        @lesson.channel_percentage_override = 0.3
        @lesson.should be_valid
      end

    end
  
  end

end
