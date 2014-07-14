require 'spec_helper'

describe ChalklerDigest do
  let(:region) { FactoryGirl.create(:region) }

  describe "course selection" do
    # this course should always be excluded from a set
    let(:course1) {
      lesson = FactoryGirl.create(:lesson, start_at: 1.day.from_now, duration: 1)
      FactoryGirl.create(:course,
                         published_at: 1.day.ago,
                         lessons: [lesson],
                         status: 'Published',
                         do_during_class: 'x',
                         meetup_url: 'http://meetup.com',
                         max_attendee: 10)
    }

    before do
      @category = FactoryGirl.create(:category)
      @chalkler = FactoryGirl.create(:chalkler, email_categories: [@category.id], email_frequency: 'daily')
      @channel = FactoryGirl.create(:channel, visible: true)
      @chalkler.channels << @channel
      @digest = ChalklerDigest.new(@chalkler)
      lesson = FactoryGirl.create(:lesson, start_at: 3.days.from_now, duration: 1)
      @course = FactoryGirl.create(:course,
                                   published_at: 1.day.ago,
                                   lessons: [lesson],
                                   status: 'Published',
                                   do_during_class: 'x',
                                   meetup_url: 'http://meetup.com',
                                   max_attendee: 15,
                                   category: @category,
                                   channel: @channel)
    end

    it "only loads new/open courses once" do
      channel = FactoryGirl.create(:channel, visible: true)
      @course.channel = channel
      @course.save!
      @chalkler.channels << channel
      courses = @digest.new_courses
      courses.concat @digest.open_courses
      courses.should == [@course]
    end

    it "only loads default new/open courses once" do
      channel = FactoryGirl.create(:channel, visible: true)
      @course.channel = channel
      @course.save!
      @chalkler.channels << channel
      courses = @digest.default_new_courses
      courses.concat @digest.default_open_courses
      courses.should == [@course]
    end

    describe "#new_courses" do
      it "loads a course that a chalkler is interested in" do
        course1.category = FactoryGirl.create(:category)
        course1.channel = @channel
        course1.save!
        @digest.new_courses.should == [@course]
      end

      it "loads a courses from channels that chalkler belongs to" do
        course1.category = @category
        course1.channel = FactoryGirl.create(:channel)
        course1.save!
        @digest.new_courses.should == [@course]
      end

      it "won't load a course without do_during_class" do
        @course.update_attribute :do_during_class, nil
        @digest.instance_eval{ new_courses }.should be_empty
      end

      it "won't load a course that is more than 1 day old" do
        @course.update_attribute :published_at, 2.days.ago
        @digest.instance_eval{ new_courses }.should be_empty
      end

      it "won't load a course from a hidden channel" do
        @channel.update_attribute :visible, false
        @digest.new_courses.should be_empty
      end

      it "only loads a course from chalkler's regions if specified" do
        @chalkler.email_region_ids = [region.id]
        @course.region = region
        @course.save!
        @digest.new_courses.should include(@course)

        @course.region = nil
        @course.save!
        @digest.new_courses.should be_empty
      end
    end

    describe "#default_new_courses" do
      it "loads a courses from channels that chalkler belongs to" do
        course1.channel = FactoryGirl.create(:channel)
        course1.save!
        @digest.default_new_courses.should == [@course]
      end

      it "won't load a course without do_during_class" do
        @course.update_attribute :do_during_class, nil
        @digest.default_new_courses.should be_empty
      end

      it "won't load a course that is more than 1 day old" do
        @course.update_attribute :published_at, 2.days.ago
        @digest.default_new_courses.should be_empty
      end

      it "won't load a course from a hidden channel" do
        @channel.update_attribute :visible, false
        @digest.default_new_courses.should be_empty
      end
    end

    describe "#open_courses" do
      before do
        @course.update_attribute :published_at, 3.days.ago
        course1.update_attribute :published_at, 3.days.ago
      end

      it "loads a course that a chalkler is interested in" do
        course1.category = FactoryGirl.create(:category)
        course1.channel = @channel
        course1.save!
        @digest.open_courses.should == [@course]
      end

      it "loads a courses from channels that chalkler belongs to" do
        course1.category = @category
        course1.channel = FactoryGirl.create(:channel)
        course1.save!
        @digest.open_courses.should == [@course]
      end

      it "won't load a full course" do
        @course.update_attribute :max_attendee, 10
        @course.bookings = []
        10.times { FactoryGirl.create(:booking, course: @course) }
        @digest.open_courses.should be_empty
      end

      it "won't load a course without do_during_class" do
        @course.update_attribute :do_during_class, nil
        @digest.open_courses.should be_empty
      end

      it "won't load a course that begins less than one day from now" do
        @course.update_attribute :start_at, Time.now.utc + 23.hours
        @digest.open_courses.should be_empty
      end

      it "won't choke on an empty set" do
        @course.destroy
        @digest.open_courses.should be_empty
      end

      it "won't load a course from a hidden channel" do
        @channel.update_attribute :visible, false
        @digest.open_courses.should be_empty
      end
    end

    describe "#default_open_courses" do
      before do
        @course.update_attribute :published_at, 3.days.ago
        course1.update_attribute :published_at, 3.days.ago
      end

      it "loads a course from channels that chalkler belongs to" do
        course1.category = @category
        course1.channel = FactoryGirl.create(:channel)
        course1.save!
        @digest.default_open_courses.should == [@course]
      end

      it "won't load a full course" do
        @course.update_attribute :max_attendee, 10
        @course.bookings = []
        10.times { FactoryGirl.create(:booking, course: @course) }
        @digest.default_open_courses.should be_empty
      end

      it "won't load a course without do_during_class" do
        @course.update_attribute :do_during_class, nil
        @digest.default_open_courses.should be_empty
      end

      it "won't load a course that begins less than one day from now" do
        @course.update_attribute :start_at, Time.now.utc + 23.hours
        @digest.default_open_courses.should be_empty
      end

      it "won't choke on an empty set" do
        @course.destroy
        @digest.default_open_courses.should be_empty
      end

      it "won't load a course from a hidden channel" do
        @channel.update_attribute :visible, false
        @digest.default_open_courses.should be_empty
      end
    end
  end

  describe ".load_chalklers" do
    it "won't return a chalkler without an email address" do
      chalkler = FactoryGirl.create(:chalkler)
      chalkler.update_attribute(:email, nil)
      ChalklerDigest.load_chalklers('weekly').should be_empty
    end

    it "won't returns a chalkler without correct frequency" do
      c = FactoryGirl.create(:chalkler, email: 'example@example.com', email_frequency: 'weekly')
      ChalklerDigest.load_chalklers('daily').should be_empty
    end

    it "will return a chalkler when email and correct email_frequency set" do
      c = FactoryGirl.create(:chalkler, email: 'example@example.com', email_frequency: 'weekly')
      ChalklerDigest.load_chalklers('weekly').should == [c]
    end
  end
end
