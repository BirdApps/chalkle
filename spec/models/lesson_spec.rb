require 'spec_helper'

describe Lesson do
  it { should have_many(:categories).through(:lesson_categories) }
  it { should have_one :lesson_image }

  it { should validate_uniqueness_of :meetup_id }
  it { should accept_nested_attributes_for :lesson_image }

  specify { FactoryGirl.create(:lesson).should be_valid }

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

  describe ".published" do
    it "should include published lessons" do
      lesson.status = "Published"
      lesson.save
      Lesson.published.should include(lesson)
    end

    it { Lesson.published.should_not include(lesson) }
  end

  describe ".upcoming" do
    before do
      { 'old' => 1.day.ago, 'soon' => 1.day.from_now, 'later' => 5.days.from_now }.each do |name, start_at|
        FactoryGirl.create(:lesson, visible: true, status: 'Published', name: name, start_at: start_at)
      end
    end

    it "should include published lessons in the future" do
      Lesson.upcoming.should include(Lesson.find_by_name('soon'), Lesson.find_by_name('later'))
      Lesson.upcoming.should_not include(Lesson.find_by_name('old'))
    end

    it "should limit lessons if limit is present" do
      Lesson.upcoming(1.day.from_now).should_not include(Lesson.find_by_name('later'))
    end
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

  describe "warning flag on lessons" do
    before do
      @teacher = FactoryGirl.create(:chalkler, name: "Teacher")
      chalkler = FactoryGirl.create(:chalkler, name: "Chalkler")
      @channel = FactoryGirl.create(:channel)
      @lesson = FactoryGirl.create(:lesson, name: "Test class", teacher_id: @teacher.id, start_at: 2.days.from_now, do_during_class: "Nothing much", teacher_cost: 10, venue_cost: 2, min_attendee: 2, venue: "Town Hall")
      FactoryGirl.create(:booking, chalkler_id: chalkler.id, lesson: @lesson, status: 'yes', guests: 5)
    end

    it "should raise warning flag when no channel is assigned" do
      @lesson.flag_warning.should == "Missing details"
      @lesson.channels << @channel
    end

    it "should raise warning flag when no teacher is assigned" do
      @lesson.update_attributes({:teacher_id => nil}, :as => :admin)
      @lesson.flag_warning.should == "Missing details"
      @lesson.update_attributes({:teacher_id => @teacher.id}, :as => :admin)
    end

    it "should raise warning flag when no date is assigned" do
      @lesson.update_attributes({:start_at => nil}, :as => :admin)
      @lesson.flag_warning.should == "Missing details"
      @lesson.update_attributes({:start_at => 2.days.from_now}, :as => :admin)
    end

    it "should raise warning flag when no venue cost is assigned" do
      @lesson.update_attributes({:venue_cost => nil}, :as => :admin)
      @lesson.flag_warning.should == "Missing details"
      @lesson.update_attributes({:venue_cost => 10}, :as => :admin)
    end

    it "should raise warning flag when no venue is assigned" do
      @lesson.update_attributes({:venue => nil}, :as => :admin)
      @lesson.flag_warning.should == "Missing details"
      @lesson.update_attributes({:venue => "Town Hall"}, :as => :admin)
    end

    it "should raise warning flag when minimum number of attendees is not reached" do
      @lesson.update_attributes({:min_attendee => 10}, :as => :admin)
      @lesson.flag_warning.should == "May cancel"
      @lesson.update_attributes({:min_attendee => 2}, :as => :admin)
    end
  end

  describe ".copy_lesson" do
    let(:chalkler) {FactoryGirl.create(:chalkler, name: "Teacher")}
    let(:channel) { FactoryGirl.create(:channel) }
    let(:category1) { FactoryGirl.create(:category, name: "Category1") }
    let(:category2) { FactoryGirl.create(:category, name: "Category2") }
    let(:lesson_original) { FactoryGirl.create(:lesson, name: "Original Lesson", teacher_id: chalkler.id, status: "Published", teacher_payment: 10, visible: false) }
    before do
      lesson_original.channels << channel
      lesson_original.categories << category1
      lesson_original.categories << category2
      @new_lesson = lesson_original.copy_lesson
    end

    it "should make a new copy with the same lesson name" do
      @new_lesson.name.should == lesson_original.name
    end

    it "should make a new copy with the same teacher" do
      @new_lesson.teacher_id.should == lesson_original.teacher_id
    end

    it "should make a new copy with the same channel" do
      @new_lesson.channels.should == lesson_original.channels
    end

    it "should make a new copy with the same categories" do
      @new_lesson.categories.should == lesson_original.categories
    end

    it "should not copy teacher payment" do
      @new_lesson.teacher_payment.should == nil
    end

    it "should have status Unreviewed" do
      @new_lesson.status.should == "Unreviewed"
    end

    it "should be visible" do
      @new_lesson.visible.should == true
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
  end

  describe "lesson costs" do

    let(:result) { MeetupApiStub::lesson_response }
    let(:channel) { FactoryGirl.create(:channel, channel_percentage: 0.2, teacher_percentage: 0.5) }

    before do
      @lesson = FactoryGirl.create(:lesson, channels: [channel])
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

    describe "pricing and profit calculations" do
      before do
        @lesson.teacher_cost = 10
        @lesson.cost = 23
        @lesson.teacher_payment = 10
        @lesson.chalkle_payment = -20
        @lesson.save
        @GST = 0.15
      end

      it "should calculate teacher percentage" do
        @lesson.teacher_percentage.should == channel.teacher_percentage
      end

      it "should calculate dollars paid to channel per attendee" do
        @lesson.channel_cost.round(2).should == (@lesson.teacher_cost/@lesson.teacher_percentage*@lesson.channel_percentage*(1 + @GST)).round(2)
      end

      it "should calculate rounding contribution to the pricing" do
        @lesson.rounding.round(2).should == (@lesson.cost - @lesson.teacher_cost*((1 + @GST)/@lesson.teacher_percentage - @GST)).round(2)
      end

      it "should calculate dollars paid to chalkle per attendee" do
        @lesson.chalkle_cost.round(2).should == (@lesson.cost - @lesson.channel_cost - @lesson.teacher_cost).round(2)
      end

      it "should calculate channel income excluding GST component" do
        @lesson.income.round(2).should == (-(@lesson.teacher_payment + @lesson.chalkle_payment)/(1 + @GST)).round(2)
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
        @lesson.cost = 20
        @lesson.teacher_cost = 10
        @lesson.chalkle_percentage_override = 0.2
        @lesson.channel_percentage_override = 0.6
        @lesson.should_not be_valid
      end

      it "should allow sum of teacher cost, channel cost and chalkle cost that differs from cost by less than 50 cents" do
        @lesson.cost = 24
        @lesson.teacher_cost = 11
        @lesson.chalkle_percentage_override = 0.2
        @lesson.channel_percentage_override = 0.3
        @lesson.should be_valid
      end

      it "when teacher cost is 0, should calculate channel cost as 0" do
        @lesson.cost = 0
        @lesson.teacher_cost = 0
        @lesson.channel_cost.should == 0
      end

      it "when teacher cost is 0, should calculate chalkle cost as 0" do
        @lesson.cost = 0
        @lesson.teacher_cost = 0
        @lesson.chalkle_cost == 0
      end

      it "when teacher cost is greater than 0 should not allow percentage overrides to cause teacher percentage to be 0" do
        @lesson.cost = 20
        @lesson.teacher_cost = 10
        @lesson.chalkle_percentage_override = 0.7
        @lesson.channel_percentage_override = 0.3
        @lesson.should_not be_valid
      end

    end

  end

end
