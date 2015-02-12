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
                         max_attendee: 10)
    }
    let(:category){FactoryGirl.create(:category)}
    let(:provider){FactoryGirl.create(:provider, visible: true)}
    let(:chalkler){ FactoryGirl.create(:chalkler, email_categories: [category.id], email_frequency: 'daily', providers: [provider])}
    let(:digest){ChalklerDigest.new(chalkler)}
    let(:lesson){FactoryGirl.create(:lesson, start_at: 3.days.from_now, duration: 3600)}
    let(:course){FactoryGirl.create(:course,
                                   published_at: 1.day.ago,
                                   lessons: [lesson],
                                   status: 'Published',
                                   do_during_class: 'x',
                                   max_attendee: 15,
                                   category: category,
                                   provider: provider)}

    it "only loads new/open courses once" do
      provider = FactoryGirl.create(:provider, visible: true)
      course.provider = provider
      course.save!
      chalkler.providers << provider
      courses = digest.new_courses
      courses.concat digest.open_courses
      expect(courses).to eq [course]
    end

    it "only loads default new/open courses once" do
      provider = FactoryGirl.create(:provider, visible: true)
      course.provider = provider
      course.save!
      chalkler.providers << provider
      courses = digest.default_new_courses
      courses.concat digest.default_open_courses
      expect(courses).to eq [course]
    end

    describe "#new_courses" do
      it "loads a course that a chalkler is interested in" do
        course1.category = FactoryGirl.create(:category)
        course1.provider = provider
        course1.save!
        expect(digest.new_courses).to eq [course]
      end

      it "loads a courses from providers that chalkler belongs to" do
        course1.category = category
        course1.provider = FactoryGirl.create(:provider)
        course1.save!
        expect(digest.new_courses).to eq [course]
      end

      it "won't load a course without do_during_class" do
        course.update_attribute :do_during_class, nil
        expect(digest.instance_eval{ new_courses }).to be_empty
      end

      it "won't load a course that is more than 1 day old" do
        course.update_attribute :published_at, 2.days.ago
        expect(digest.instance_eval{ new_courses }).to be_empty
      end

      it "won't load a course from a hidden provider" do
        provider.update_attribute :visible, false
        expect(digest.new_courses).to be_empty
      end

      it "only loads a course from chalkler's regions if specified" do
        course.published_at = Time.now
        chalkler.email_region_ids = [region.id]
        course.region = region
        course.save!
        
        expect(digest.new_courses).to include(course)
        course.region = nil
        course.save!
        expect(digest.new_courses).to be_empty
      end
    end

    describe "#default_new_courses" do
      it "loads a courses from providers that chalkler belongs to" do
        course1.provider = FactoryGirl.create(:provider)
        course1.save!
        expect(digest.default_new_courses).to eq [course]
      end

      it "won't load a course without do_during_class" do
        course.update_attribute :do_during_class, nil
        expect(digest.default_new_courses).to be_empty
      end

      it "won't load a course that is more than 1 day old" do
        course.update_attribute :published_at, 2.days.ago
        expect(digest.default_new_courses).to be_empty
      end

      it "won't load a course from a hidden provider" do
        provider.update_attribute :visible, false
        expect(digest.default_new_courses).to be_empty
      end
    end

    describe "#open_courses" do
      before do
        course.update_attribute :published_at, 3.days.ago
        course1.update_attribute :published_at, 3.days.ago
      end

      it "loads a course that a chalkler is interested in" do
        course1.category = FactoryGirl.create(:category)
        course1.provider = provider
        course1.save!
        expect(digest.open_courses).to eq [course]
      end

      it "loads a courses from providers that chalkler belongs to" do
        course1.category = category
        course1.provider = FactoryGirl.create(:provider)
        course1.save!
        expect(digest.open_courses).to eq [course]
      end

      it "won't load a full course" do
        course.update_attribute :max_attendee, 10
        course.bookings = []
        10.times { FactoryGirl.create(:booking, course: course) }
        expect(digest.open_courses).to be_empty
      end

      it "won't load a course without do_during_class" do
        course.update_attribute :do_during_class, nil
        expect(digest.open_courses).to be_empty
      end

      it "won't choke on an empty set" do
        course.destroy
        expect(digest.open_courses).to be_empty
      end

      it "won't load a course from a hidden provider" do
        provider.update_attribute :visible, false
        expect(digest.open_courses).to be_empty
      end
    end

    describe "#default_open_courses" do
      before do
        course.update_attribute :published_at, 3.days.ago
        course1.update_attribute :published_at, 3.days.ago
      end

      it "loads a course from providers that chalkler belongs to" do
        course1.category = category
        course1.provider = FactoryGirl.create(:provider)
        course1.save!
        expect(digest.default_open_courses).to eq [course]
      end

      it "won't load a full course" do
        course.update_attribute :max_attendee, 10
        course.bookings = []
        10.times { FactoryGirl.create(:booking, course: course) }
        expect(digest.default_open_courses).to be_empty
      end

      it "won't load a course without do_during_class" do
        course.update_attribute :do_during_class, nil
        expect(digest.default_open_courses).to be_empty
      end

      it "won't choke on an empty set" do
        course.destroy
        expect(digest.default_open_courses).to be_empty
      end

      it "won't load a course from a hidden provider" do
        provider.update_attribute :visible, false
        expect(digest.default_open_courses).to be_empty
      end
    end
  end

  describe ".load_chalklers" do
    it "won't return a chalkler without an email address" do
      chalkler = FactoryGirl.create(:chalkler)
      chalkler.update_attribute(:email, nil)
      expect(ChalklerDigest.load_chalklers('weekly')).to be_empty
    end

    it "won't returns a chalkler without correct frequency" do
      c = FactoryGirl.create(:chalkler, email: 'example@example.com', email_frequency: 'weekly')
      expect(ChalklerDigest.load_chalklers('daily')).to be_empty
    end

    it "will return a chalkler when email and correct email_frequency set" do
      c = FactoryGirl.create(:chalkler, email: 'example@example.com', email_frequency: 'weekly')
      expect(ChalklerDigest.load_chalklers('weekly')).to eq [c]
    end
  end
end
