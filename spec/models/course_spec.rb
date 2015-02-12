require 'spec_helper'

describe Course do
  
  it { should belong_to :provider }
  it { should belong_to :teacher }

  it { should accept_nested_attributes_for :lessons }

  specify { expect(FactoryGirl.create(:course)).to be_valid }

  let(:course) { FactoryGirl.create(:course) }

  describe "column validations" do
    it "should not allow non valid status" do
      course.status = "resres"
      expect(course).not_to be_valid
    end
  end

  describe ".visible" do
    it { expect(Course.visible).to include(course) }

   	it "should not include hidden course" do
      course.visible = false
      course.save
      expect(Course.visible).not_to include(course)
    end
  end

  describe ".by_date" do
    it "should sort by its earliest lesson" do
      lesson1 = FactoryGirl.create(:lesson, start_at: Time.now + 1.day)
      lesson2 = FactoryGirl.create(:lesson, start_at: Time.now + 2.days)
      lesson3 = FactoryGirl.create(:lesson, start_at: Time.now + 3.days)
      lesson4 = FactoryGirl.create(:lesson, start_at: Time.now + 4.days)
      lesson5 = FactoryGirl.create(:lesson, start_at: Time.now + 5.days)
      lesson6 = FactoryGirl.create(:lesson, start_at: Time.now + 6.days)
      course2 = FactoryGirl.create(:course, lessons: [lesson1, lesson6])
      course1 = FactoryGirl.create(:course, lessons: [lesson5, lesson6])
      course3 = FactoryGirl.create(:course, lessons: [lesson2, lesson4])
      expect(Course.by_date.index(course3) < Course.by_date.index(course1) && Course.by_date.index(course2) < Course.by_date.index(course1)).to be true   
    end
  end

  describe ".hidden" do
    it "should include hidden course" do
      course.visible = false
      course.save
      expect(Course.hidden).to include(course)
   	end

    it { expect(Course.hidden).not_to include(course) }
  end

  context "publication" do
    describe ".published" do
      it "should include published courses" do
        course.status = Course::STATUS_1
        course.save
        expect(Course.published).to include(course)
      end

      it { 
        course.status = Course::STATUS_1
        course.save
        expect(Course.published).to include(course) 
      }
    end

    it "sets published at to now if it is nil" do
      course.status = Course::STATUS_1
      course.save!
      expect(course.published_at).to be_within(10.seconds).of(Time.now)
    end

    it "doesn't override published at if already set" do
      course.status = Course::STATUS_1
      course.published_at = 1.day.ago
      course.save!
      expect(course.published_at).to be_within(10.seconds).of(1.day.ago)
    end
  end

  describe ".upcoming" do
    let!(:old) { FactoryGirl.create(:course, lessons: [ FactoryGirl.create(:lesson, start_at: 1.day.ago)], duration: 1) }
    let!(:soon) { FactoryGirl.create(:course, lessons: [ FactoryGirl.create(:lesson, start_at: 1.day.from_now)], duration: 1) }
    let!(:later) { FactoryGirl.create(:course, lessons: [ FactoryGirl.create(:lesson, start_at: 5.days.from_now)], duration: 1) }

    it "should include published courses in the future" do
      expect(Course.upcoming).to include(soon, later)
      expect(Course.upcoming).not_to include(old)
    end

    it "should limit courses if limit is present" do
      expect(Course.upcoming(1.day.from_now)).not_to include(later)
    end
  end

  describe ".in_future" do
    let!(:lesson) { FactoryGirl.create(:lesson, start_at: Time.current + 5.hours, duration: 1) }
    let(:course) { FactoryGirl.create(:course, lessons: [lesson]) }

    it "includes course published earlier today" do
      Timecop.freeze(Time.current) do
        expect(Course.in_future).to include(course)
      end
    end

    it "includes course published later today" do
      Timecop.freeze(Time.current) do
        expect(Course.in_future).to include(course)
      end
    end
  end
  describe "warning flag on courses" do

      let(:teacher)  { FactoryGirl.create(:provider_teacher, name: "Teacher") }
      let(:chalkler) { FactoryGirl.create(:chalkler, name: "Chalkler") }
      let(:provider) { FactoryGirl.create(:provider) }
      let(:lesson) { FactoryGirl.create(:lesson, start_at: 2.days.from_now, duration: 1.5) }
      let(:course) { FactoryGirl.create(:course, name: "Test class", teacher_id: teacher.id, lessons: [lesson], do_during_class: "Nothing much", teacher_cost: 10, min_attendee: 2, venue: "Town Hall") }
      let(:booking) { FactoryGirl.create(:booking, chalkler: chalkler, course: course, status: 'yes', guests: 5) }

    it "should not be valid if published with no lessons and published" do
      course.lessons = []
      course.visible = true
      course.status = Course::STATUS_1
      expect(course).not_to be_valid
      course.lessons << FactoryGirl.create(:lesson, start_at: 2.days.from_now)
      expect(course).to be_valid
    end
  end

  describe "course costs" do

    let(:provider) { FactoryGirl.create(:provider, provider_rate_override: 0.2, teacher_percentage: 0.5) }

    let(:course) { FactoryGirl.create(:course, provider: provider, cost: 20) }
      
    describe "cost validations" do

      it "should not allow non numercial cost" do
        course.cost = "resres"
        expect(course).not_to be_valid
      end

      it "should not allow negative cost" do
        course.cost = -10
        expect(course).not_to be_valid
      end

    end
  end

  describe ".create_outgoing_payments!" do
    let(:provider) { FactoryGirl.create(:provider) }
    let(:teacher){ FactoryGirl.create(:provider_teacher, provider: provider )}
    let(:lesson){ FactoryGirl.create(:past_lesson)}
    let(:course) { FactoryGirl.create(:course_with_bookings, provider: provider, teacher: teacher, status: 'Completed', lessons: [lesson])}

    it "should associate a completed course with a teacher_payment and a provider_payment" do
      course.create_outgoing_payments!
      expect(course.teacher_payment).to(be_valid) && 
      expect(course.provider_payment).to(be_valid)
    end
  end
end
