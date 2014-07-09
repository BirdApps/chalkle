require 'spec_helper'

describe Course do
  it { should belong_to(:category) }
  it { should have_one :course_image }

  it { should validate_uniqueness_of :meetup_id }
  it { should accept_nested_attributes_for :course_image }

  specify { FactoryGirl.create(:course).should be_valid }

  let(:course) { FactoryGirl.create(:course) }

  describe "column validations" do
    it "should not allow non valid status" do
      course.status = "resres"
      course.should_not be_valid
    end
  end

  describe ".visible" do
    it { Course.visible.should include(course) }

   	it "should not include hidden course" do
      course.visible = false
      course.save
      Course.visible.should_not include(course)
    end
  end

  describe ".hidden" do
    it "should include hidden course" do
      course.visible = false
      course.save
      Course.hidden.should include(course)
   	end

    it { Course.hidden.should_not include(course) }
  end

  context "publication" do
    describe ".published" do
      it "should include published courses" do
        course.status = Course::STATUS_1
        course.save
        Course.published.should include(course)
      end

      it { Course.published.should_not include(course) }
    end

    it "sets published at to now if it is nil" do
      course.status = Course::STATUS_1
      course.save!
      course.published_at.should be_within(10.seconds).of(Time.now)
    end

    it "doesn't override published at if already set" do
      course.status = Course::STATUS_1
      course.published_at = 1.day.ago
      course.save!
      course.published_at.should be_within(10.seconds).of(1.day.ago)
    end
  end

  describe ".upcoming" do
    before do
      { 'old' => 1.day.ago, 'soon' => 1.day.from_now, 'later' => 5.days.from_now }.each do |name, start_at|
        FactoryGirl.create(:course, visible: true, status: 'Published', name: name, start_at: start_at)
      end
    end

    it "should include published courses in the future" do
      Course.upcoming.should include(Course.find_by_name('soon'), Course.find_by_name('later'))
      Course.upcoming.should_not include(Course.find_by_name('old'))
    end

    it "should limit courses if limit is present" do
      Course.upcoming(1.day.from_now).should_not include(Course.find_by_name('later'))
    end
  end

  describe ".upcoming_or_today" do
    it "includes course published earlier today" do
      day_start = Time.new(2013,1,1,0,5)
      day_middle = Time.new(2013,1,1,12,0)

      course = FactoryGirl.create(:course, start_at: day_start)

      Timecop.freeze(day_middle) do
        Course.upcoming_or_today.should include(course)
      end
    end

    it "includes course published later today" do
      day_start = Time.new(2013,1,1,0,5,0)
      day_middle = Time.new(2013,1,1,12,0,0)

      course = FactoryGirl.create(:course, start_at: day_middle)

      Timecop.freeze(day_start) do
        Course.upcoming_or_today.should include(course)
      end
    end
  end

  describe "cancellation email" do
    let(:course2) { FactoryGirl.create(:course, start_at: Date.today, min_attendee: 3) }

    it "sends cancellation email for too little bookings" do
      course2.class_may_cancel.should be_true
    end

    it "do not send cancellation email for sufficient bookings" do
      booking = FactoryGirl.create(:booking, course: course2, status: 'yes', guests: 5)
      course2.class_may_cancel.should be_false
    end
  end

  describe "warning flag on courses" do
    before do
      @teacher = FactoryGirl.create(:chalkler, name: "Teacher")
      chalkler = FactoryGirl.create(:chalkler, name: "Chalkler")
      @channel = FactoryGirl.create(:channel)
      @course = FactoryGirl.create(:course, name: "Test class", teacher_id: @teacher.id, start_at: 2.days.from_now, do_during_class: "Nothing much", teacher_cost: 10, venue_cost: 2, min_attendee: 2, venue: "Town Hall")
      FactoryGirl.create(:booking, chalkler_id: chalkler.id, course: @course, status: 'yes', guests: 5)
    end

    it "should raise warning flag when no channel is assigned" do
      @course.channel = nil
      @course.flag_warning.should == "Missing details"
    end

    it "should raise warning flag when no teacher is assigned" do
      @course.update_attributes({:teacher_id => nil}, :as => :admin)
      @course.flag_warning.should == "Missing details"
      @course.update_attributes({:teacher_id => @teacher.id}, :as => :admin)
    end

    it "should raise warning flag when no date is assigned" do
      @course.update_attributes({:start_at => nil}, :as => :admin)
      @course.flag_warning.should == "Missing details"
      @course.update_attributes({:start_at => 2.days.from_now}, :as => :admin)
    end

    it "should raise warning flag when no venue cost is assigned" do
      @course.update_attributes({:venue_cost => nil}, :as => :admin)
      @course.flag_warning.should == "Missing details"
      @course.update_attributes({:venue_cost => 10}, :as => :admin)
    end

    it "should raise warning flag when no venue is assigned" do
      @course.update_attributes({:venue => nil}, :as => :admin)
      @course.flag_warning.should == "Missing details"
      @course.update_attributes({:venue => "Town Hall"}, :as => :admin)
    end

    it "should raise warning flag when minimum number of attendees is not reached" do
      @course.update_attributes({:min_attendee => 10}, :as => :admin)
      @course.flag_warning.should == "May cancel"
      @course.update_attributes({:min_attendee => 2}, :as => :admin)
    end
  end

  describe ".copy_course" do
    let(:chalkler) {FactoryGirl.create(:chalkler, name: "Teacher")}
    let(:channel) { FactoryGirl.create(:channel) }
    let(:category) { FactoryGirl.create(:category, name: "Category1") }
    let(:course_original) { FactoryGirl.create(:course, name: "Original Course", teacher_id: chalkler.id, status: "Published", teacher_payment: 10, visible: false, category: category) }
    before do
      course_original.channel = channel
      course_original.category = category
      @new_course = course_original.copy_course
    end

    it "should make a new copy with the same course name" do
      @new_course.name.should == course_original.name
    end

    it "should make a new copy with the same teacher" do
      @new_course.teacher_id.should == course_original.teacher_id
    end

    it "should make a new copy with the same channel" do
      @new_course.channel.should == course_original.channel
    end

    it "should make a new copy with the same category" do
      @new_course.category.should == course_original.category
    end

    it "should not copy teacher payment" do
      @new_course.teacher_payment.should == nil
    end

    it "should have status Unreviewed" do
      @new_course.status.should == "Unreviewed"
    end

    it "should be visible" do
      @new_course.visible.should == true
    end
  end

  context "categories" do
    describe "#set_category" do
      it "should create an association" do
        category = FactoryGirl.create(:category, name: "category")
        course = FactoryGirl.create(:course)
        course.set_category 'category: a new course'
        course.category.should == category
      end
    end
  end

  describe "#set_name" do
    before do
      @course = Course.new
    end

    it "returns text after the colon" do
      @course.set_name('zzz: xxx').should == 'xxx'
    end

    it "strips whitespace from the course name" do
      @course.set_name(' xxx ').should == 'xxx'
    end
  end

  describe "material cost validation" do
    before do
      @course = FactoryGirl.create(:course)
    end
    it "assigns default material cost" do
      @course.material_cost.should == 0
    end

    it "does not allow non numerical costs" do
      @course.material_cost = "rewrew"
      @course.should_not be_valid
    end
  end

  describe "course costs" do

    let(:result) { MeetupApiStub::course_response }
    let(:channel) { FactoryGirl.create(:channel, channel_rate_override: 0.2, teacher_percentage: 0.5) }

    before do
      @course = FactoryGirl.create(:course, channel: channel)
      @course.cost = 20
      @course.save
    end

    describe "cost validations" do
      it "should not allow non numercial teacher cost" do
        @course.teacher_cost = "resres"
        @course.should_not be_valid
      end

      it "should not allow non numercial cost" do
        @course.cost = "resres"
        @course.should_not be_valid
      end

      it "should not allow negative cost" do
        @course.cost = -10
        @course.should_not be_valid
      end

      it "should not allow non numerical teacher payment" do
        @course.teacher_payment = "resres"
        @course.should_not be_valid
      end

      it "should not allow teacher cost greater than cost" do
        @course.teacher_cost = 40
        @course.should_not be_valid
      end

    end


    describe "GST" do
      it "should know the gst for supported region" do
        @course.gst_rate_for(:nz).should = 0.15 
      end
    end

    describe "pricing and profit calculations" do
      before do
        @course.teacher_cost = 10
        @course.cost = 23
        @course.teacher_payment = 10
        @course.chalkle_payment = -20
        @course.save
        @GST = 0.15
      end

      it "should calculate channel income excluding GST component" do
        @course.income.round(2).should == (-(@course.teacher_payment + @course.chalkle_payment)/(1 + @GST)).round(2)
      end
    end
  end
end
