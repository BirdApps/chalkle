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
      @chalkler = FactoryGirl.create(:chalkler, email_categories: [@category.id])
      @channel = FactoryGirl.create(:channel)
      @chalkler.channels << @channel
      @digest = ChalklerDigest.new(@chalkler)
    end

    describe "#new_lessons" do
      it "loads a lesson that a chalkler is interested in" do
        lesson = FactoryGirl.create(:lesson, created_at: 1.day.ago, status: 'Published')
        lesson.categories << @category
        lesson.channels << @channel
        lesson1 =  FactoryGirl.create(:lesson, created_at: 1.day.ago, status: 'Published')
        lesson1.channels << @channel
        @digest.instance_eval{ new_lessons }.count.should == 1
      end

      it "loads a lessons from channels that chalkler belongs to" do
        lesson = FactoryGirl.create(:lesson, created_at: 1.day.ago, status: 'Published')
        lesson.categories << @category
        lesson.channels << @channel
        lesson1 =  FactoryGirl.create(:lesson, created_at: 1.day.ago, status: 'Published')
        lesson1.categories << @category
        lesson1.channels << FactoryGirl.create(:channel)
        @digest.instance_eval{ new_lessons }.count.should == 1
      end

      pending "won't load a lesson that is X old" do
      end

      pending "won't load a lesson that is X new" do
      end
    end

    describe "#default_new_lessons" do
      it "loads a lessons from channels that chalkler belongs to" do
        lesson = FactoryGirl.create(:lesson, created_at: 1.day.ago, status: 'Published')
        lesson.channels << @channel
        lesson1 =  FactoryGirl.create(:lesson, created_at: 1.day.ago, status: 'Published')
        lesson1.channels << FactoryGirl.create(:channel)
        @digest.instance_eval{ default_new_lessons }.count.should == 1
      end

      pending "won't load a lesson that is X old" do
      end

      pending "won't load a lesson that is X new" do
      end
    end

    describe "open_lessons" do
      it "loads a lesson that a chalkler is interested in" do
        lesson = FactoryGirl.create(:lesson, created_at: 1.day.ago, status: 'Published')
        lesson.categories << @category
        lesson.channels << @channel
        lesson1 =  FactoryGirl.create(:lesson, created_at: 1.day.ago, status: 'Published')
        lesson1.channels << @channel
        @digest.instance_eval{ new_lessons }.count.should == 1
      end

      it "loads a lessons from channels that chalkler belongs to" do
        lesson = FactoryGirl.create(:lesson, created_at: 1.day.ago, status: 'Published')
        lesson.categories << @category
        lesson.channels << @channel
        lesson1 =  FactoryGirl.create(:lesson, created_at: 1.day.ago, status: 'Published')
        lesson1.categories << @category
        lesson1.channels << FactoryGirl.create(:channel)
        @digest.instance_eval{ new_lessons }.count.should == 1
      end

      pending "only loads lessons with open rsvps" do
      end

      pending "won't load a lesson that is X old" do
      end

      pending "won't load a lesson that is X new" do
      end
    end

    describe "#default_open_lessons" do
      it "loads a lessons from channels that chalkler belongs to" do
        lesson = FactoryGirl.create(:lesson, created_at: 1.day.ago, status: 'Published')
        lesson.channels << @channel
        lesson1 =  FactoryGirl.create(:lesson, created_at: 1.day.ago, status: 'Published')
        lesson1.channels << FactoryGirl.create(:channel)
        @digest.instance_eval{ default_new_lessons }.count.should == 1
      end

      pending "only loads lessons with open rsvps" do
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
      ChalklerDigest.load_chalklers('weekly').count.should == 1
    end
  end
end
