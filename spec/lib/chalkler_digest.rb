require 'spec_helper'
require 'chalkler_digest'

describe ChalklerDigest do
  describe "#initialize" do
    let(:chalkler){ FactoryGirl.create(:chalkler, email_frequency: 'daily') }
    let(:digest) { ChalklerDigest.new(chalkler) }

    it "sets @chalkler" do
      digest.instance_eval{ @chalkler }.should == chalkler
    end

    it "sets @frequency" do
      digest.instance_eval{ @frequency }.should == 'daily'
    end

    it "sets @limit" do
      digest.instance_eval{ @limit }.should == 5
    end
  end

  describe "lesson selection" do
    before do
      @category = FactoryGirl.create(:category)
      @chalkler = FactoryGirl.create(:chalkler, email_categories: [@category.id], email_frequency: 'daily')
      @channel = FactoryGirl.create(:channel)
      @chalkler.channels << @channel
      @digest = ChalklerDigest.new(@chalkler)
      @lesson = FactoryGirl.create(:lesson,
                                   created_at: 1.day.ago,
                                   start_at: 3.days.from_now,
                                   status: 'Published',
                                   do_during_class: 'x')
      @lesson.categories << @category
      @lesson.channels << @channel
    end

    describe "#new_lessons" do
      it "loads a lesson that a chalkler is interested in" do
        lesson1 = FactoryGirl.create(:lesson, created_at: 1.day.ago, status: 'Published', do_during_class: 'x')
        lesson1.channels << @channel
        @digest.instance_eval{ new_lessons }.should == [@lesson]
      end

      it "loads a lessons from channels that chalkler belongs to" do
        lesson1 = FactoryGirl.create(:lesson, created_at: 1.day.ago, status: 'Published', do_during_class: 'x')
        lesson1.categories << @category
        lesson1.channels << FactoryGirl.create(:channel)
        @digest.instance_eval{ new_lessons }.should == [@lesson]
      end

      it "won't load a lesson without meetup_url" do
        @lesson.update_attribute :meetup_url, nil
        @digest.instance_eval{ new_lessons }.should be_empty
      end

      it "won't load a lesson without do_during_class" do
        @lesson.update_attribute :do_during_class, nil
        @digest.instance_eval{ new_lessons }.should be_empty
      end

      it "won't load a lesson that is more than 1 day old" do
        @lesson.update_attribute :created_at, 2.days.ago
        @digest.instance_eval{ new_lessons }.should be_empty
      end

      it "won't load a lesson that was created today" do
        @lesson.update_attribute :created_at, Time.now
        @digest.instance_eval{ new_lessons }.should be_empty
      end
    end

    describe "#default_new_lessons" do
      it "loads a lessons from channels that chalkler belongs to" do
        lesson1 = FactoryGirl.create(:lesson, created_at: 1.day.ago, status: 'Published', do_during_class: 'x')
        lesson1.channels << FactoryGirl.create(:channel)
        @digest.instance_eval{ default_new_lessons }.should == [@lesson]
      end

      it "won't load a lesson without meetup_url" do
        @lesson.update_attribute :meetup_url, nil
        @digest.instance_eval{ default_new_lessons }.should be_empty
      end

      it "won't load a lesson without do_during_class" do
        @lesson.update_attribute :do_during_class, nil
        @digest.instance_eval{ default_new_lessons }.should be_empty
      end

      it "won't load a lesson that is more than 1 day old" do
        @lesson.update_attribute :created_at, 2.days.ago
        @digest.instance_eval{ default_new_lessons }.should be_empty
      end

      it "won't load a lesson that was created today" do
        @lesson.update_attribute :created_at, Time.now
        @digest.instance_eval{ default_new_lessons }.should be_empty
      end
    end

    describe "#open_lessons" do
      pending "loads a lesson that a chalkler is interested in" do
        lesson1 = FactoryGirl.create(:lesson, created_at: 1.day.ago, status: 'Published', do_during_class: 'x')
        lesson1.channels << @channel
        @digest.instance_eval{ open_lessons }.should == [@lesson]
      end

      pending "loads a lessons from channels that chalkler belongs to" do
        lesson1 = FactoryGirl.create(:lesson, created_at: 1.day.ago, status: 'Published', do_during_class: 'x')
        lesson1.categories << @category
        lesson1.channels << FactoryGirl.create(:channel)
        @digest.instance_eval{ open_lessons }.should == [@lesson]
      end

      pending "only loads lessons with open rsvps" do
      end

      it "won't load a lesson without meetup_url" do
        @lesson.update_attribute :meetup_url, nil
        @digest.instance_eval{ open_lessons }.should be_empty
      end

      it "won't load a lesson without do_during_class" do
        @lesson.update_attribute :do_during_class, nil
        @digest.instance_eval{ open_lessons }.should be_empty
      end

      it "won't load a lesson that is more than 1 day old" do
        @lesson.update_attribute :created_at, 2.days.ago
        @digest.instance_eval{ open_lessons }.should be_empty
      end

      it "won't load a lesson that was created today" do
        @lesson.update_attribute :created_at, Time.now
        @digest.instance_eval{ open_lessons }.should be_empty
      end
    end

    describe "#default_open_lessons" do
      pending "loads a lessons from channels that chalkler belongs to" do
        lesson1 =  FactoryGirl.create(:lesson, created_at: 1.day.ago, status: 'Published', do_during_class: 'x')
        lesson1.channels << FactoryGirl.create(:channel)
        @digest.instance_eval{ default_open_lessons }.should == [@lesson]
      end

      pending "only loads lessons with open rsvps" do
      end

      it "won't load a lesson without meetup_url" do
        @lesson.update_attribute :meetup_url, nil
        @digest.instance_eval{ default_open_lessons }.should be_empty
      end

      it "won't load a lesson without do_during_class" do
        @lesson.update_attribute :do_during_class, nil
        @digest.instance_eval{ default_open_lessons }.should be_empty
      end

      pending "won't load a lesson that is X old" do
      end

      pending "won't load a lesson that is X new" do
      end
    end
  end

  describe ".load_chalklers" do
    it "won't return a chalkler without an email address" do
      FactoryGirl.create(:chalkler, email: nil, email_frequency: 'weekly')
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
