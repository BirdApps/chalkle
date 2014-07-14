require 'spec_helper'

describe Lesson do
  it { lesson.should belong_to(:category) }
  it { lesson.should have_one :lesson_image }
  it { lesson.should accept_nested_attributes_for :lesson_image }

  specify { expect(FactoryGirl.create(:lesson)).to be_valid }

  let(:lesson) { FactoryGirl.create(:lesson) }

  describe "column validations" do
    it "should not allow non valid status" do
      lesson.status = "resres"
      expect(lesson).not_to be_valid
    end
  end

  describe ".visible" do
    it { expect(Lesson.visible).to include(lesson) }

   	it "should not include hidden lesson" do
      lesson.visible = false
      lesson.save
      expect(Lesson.visible).not_to include(lesson)
    end
  end

  describe ".hidden" do
    it "should include hidden lesson" do
      lesson.visible = false
      lesson.save
      expect(Lesson.hidden).to include(lesson)
   	end

    it { expect(Lesson.hidden).not_to include(lesson) }
  end

  context "publication" do
    describe ".published" do
      it "should include published lessons" do
        lesson.status = Lesson::STATUS_1
        lesson.save
        expect(Lesson.published).to include(lesson)
      end

      it { expect(Lesson.published).not_to include(lesson) }
    end

    it "sets published at to now if it is nil" do
      lesson.status = Lesson::STATUS_1
      lesson.save!
      expect(lesson.published_at).to be_within(10.seconds).of(Time.now)
    end

    it "doesn't override published at if already set" do
      lesson.status = Lesson::STATUS_1
      lesson.published_at = 1.day.ago
      lesson.save!
      expect(lesson.published_at).to be_within(10.seconds).of(1.day.ago)
    end
  end

  describe ".upcoming" do
    before do
      { 'old' => 1.day.ago, 'soon' => 1.day.from_now, 'later' => 5.days.from_now }.each do |name, start_at|
        FactoryGirl.create(:lesson, visible: true, status: 'Published', name: name, start_at: start_at)
      end
    end

    it "should include published lessons in the future" do
      expect(Lesson.upcoming).to include(Lesson.find_by_name('soon'), Lesson.find_by_name('later'))
      expect(Lesson.upcoming).not_to include(Lesson.find_by_name('old'))
    end

    it "should limit lessons if limit is present" do
      expect(Lesson.upcoming(1.day.from_now)).not_to include(Lesson.find_by_name('later'))
    end
  end

  describe ".upcoming_or_today" do
    it "includes lesson published earlier today" do
      day_start = Time.new(2013,1,1,0,5)
      day_middle = Time.new(2013,1,1,12,0)

      lesson = FactoryGirl.create(:lesson, start_at: day_start)

      Timecop.freeze(day_middle) do
        expect(Lesson.upcoming_or_today).to include(lesson)
      end
    end

    it "includes lesson published later today" do
      day_start = Time.new(2013,1,1,0,5,0)
      day_middle = Time.new(2013,1,1,12,0,0)

      lesson = FactoryGirl.create(:lesson, start_at: day_middle)

      Timecop.freeze(day_start) do
        expect(Lesson.upcoming_or_today).to include(lesson)
      end
    end
  end

  describe "cancellation email" do
    let(:lesson2) { FactoryGirl.create(:lesson, start_at: Date.today, min_attendee: 3) }

    it "sends cancellation email for too little bookings" do
      expect(lesson2.class_may_cancel).to be true
    end

    it "do not send cancellation email for sufficient bookings" do
      booking = FactoryGirl.create(:booking, lesson: lesson2, status: 'yes', guests: 5)
      expect(lesson2.class_may_cancel).to be false
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
      @lesson.channel = nil
      expect(@lesson.flag_warning).to eq "Missing details"
    end

    it "should raise warning flag when no teacher is assigned" do
      @lesson.update_attributes({:teacher_id => nil}, :as => :admin)
      expect(@lesson.flag_warning).to eq "Missing details"
      @lesson.update_attributes({:teacher_id => @teacher.id}, :as => :admin)
    end

    it "should raise warning flag when no date is assigned" do
      @lesson.update_attributes({:start_at => nil}, :as => :admin)
      expect(@lesson.flag_warning).to eq "Missing details"
      @lesson.update_attributes({:start_at => 2.days.from_now}, :as => :admin)
    end

    it "should raise warning flag when no venue cost is assigned" do
      @lesson.update_attributes({:venue_cost => nil}, :as => :admin)
      expect(@lesson.flag_warning).to eq "Missing details"
      @lesson.update_attributes({:venue_cost => 10}, :as => :admin)
    end

    it "should raise warning flag when no venue is assigned" do
      @lesson.update_attributes({:venue => nil}, :as => :admin)
      expect(@lesson.flag_warning).to eq "Missing details"
      @lesson.update_attributes({:venue => "Town Hall"}, :as => :admin)
    end

    it "should raise warning flag when minimum number of attendees is not reached" do
      @lesson.update_attributes({:min_attendee => 10}, :as => :admin)
      expect(@lesson.flag_warning).to eq "May cancel"
      @lesson.update_attributes({:min_attendee => 2}, :as => :admin)
    end
  end

  describe ".copy_lesson" do
    let(:chalkler) {FactoryGirl.create(:chalkler, name: "Teacher")}
    let(:channel) { FactoryGirl.create(:channel) }
    let(:category) { FactoryGirl.create(:category, name: "Category1") }
    let(:lesson_original) { FactoryGirl.create(:lesson, name: "Original Lesson", teacher_id: chalkler.id, status: "Published", teacher_payment: 10, visible: false, category: category) }
    before do
      lesson_original.channel = channel
      lesson_original.category = category
      @new_lesson = lesson_original.copy_lesson
    end

    it "should make a new copy with the same lesson name" do
      expect(@new_lesson.name).to eq lesson_original.name
    end

    it "should make a new copy with the same teacher" do
      expect(@new_lesson.teacher_id).to eq lesson_original.teacher_id
    end

    it "should make a new copy with the same channel" do
      expect(@new_lesson.channel).to eq lesson_original.channel
    end

    it "should make a new copy with the same category" do
      expect(@new_lesson.category).to eq lesson_original.category
    end

    it "should not copy teacher payment" do
      expect(@new_lesson.teacher_payment).to eq nil
    end

    it "should have status Unreviewed" do
      expect(@new_lesson.status).to eq "Unreviewed"
    end

    it "should be visible" do
      expect(@new_lesson.visible).to eq true
    end
  end

  context "categories" do
    describe "#set_category" do
      it "should create an association" do
        category = FactoryGirl.create(:category, name: "category")
        lesson = FactoryGirl.create(:lesson)
        lesson.set_category 'category: a new lesson'
        expect(lesson.category).to eq category
      end
    end
  end

  describe "#set_name" do
    before do
      @lesson = Lesson.new
    end

    it "returns text after the colon" do
      expect(@lesson.set_name('zzz: xxx')).to eq 'xxx'
    end

    it "strips whitespace from the lesson name" do
      expect(@lesson.set_name(' xxx ')).to eq 'xxx'
    end
  end

  describe "material cost validation" do
    before do
      @lesson = FactoryGirl.create(:lesson)
    end
    it "assigns default material cost" do
      expect(@lesson.material_cost).to eq 0
    end

    it "does not allow non numerical costs" do
      @lesson.material_cost = "rewrew"
expect(@lesson).not_to be_valid
    end
  end

  describe "lesson costs" do

    let(:result) { MeetupApiStub::lesson_response }
    let(:channel) { FactoryGirl.create(:channel, channel_rate_override: 0.2, teacher_percentage: 0.5) }

    before do
      @lesson = FactoryGirl.create(:lesson, channel: channel)
      @lesson.cost = 20
      @lesson.save
    end

    describe "cost validations" do
      it "should not allow non numercial teacher cost" do
        @lesson.teacher_cost = "resres"
        expect(@lesson).not_to be_valid
      end

      it "should not allow non numercial cost" do
        @lesson.cost = "resres"
        expect(@lesson).not_to be_valid
      end

      it "should not allow negative cost" do
        @lesson.cost = -10
        expect(@lesson).not_to be_valid
      end

      it "should not allow non numerical teacher payment" do
        @lesson.teacher_payment = "resres"
        expect(@lesson).not_to be_valid
      end

      it "should not allow teacher cost greater than cost" do
        @lesson.teacher_cost = 40
        expect(@lesson).not_to be_valid
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

      it "should calculate channel income excluding GST component" do
        expect(@lesson.income.round(2)).to eq (-(@lesson.teacher_payment + @lesson.chalkle_payment)/(1 + @GST)).round(2)
      end
    end
  end
end
