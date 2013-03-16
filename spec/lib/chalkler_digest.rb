require 'spec_helper'
require 'chalkler_digest'

describe ChalklerDigest do
  describe "#initialize" do
    let(:chalkler){ FactoryGirl.create(:chalkler, email_frequency: 'daily') }

    it "sets @chalkler" do
      digest = ChalklerDigest.new(chalkler)
      digest.instance_eval{ @chalkler }.should == chalkler
    end

    it "sets @frequency" do
      digest = ChalklerDigest.new(chalkler)
      digest.instance_eval{ @frequency }.should == 'daily'
    end
  end

  describe "new_lessons" do
    let(:category) { FactoryGirl.create(:category) }
    let(:chalkler) { FactoryGirl.create(:chalkler, email_categories: [category.id]) }

    it "won't load a lesson that is unpublished" do
      lesson = FactoryGirl.create(:lesson, created_at: 1.day.ago, status: 'Approved')
      lesson.categories << category
      digest = ChalklerDigest.new(chalkler)
      digest.new_lessons.should be_empty
    end

    it "loads a lesson that a chalkler is interested in" do
      lesson = FactoryGirl.create(:lesson, created_at: 1.day.ago, status: 'Published')
      lesson.categories << category
      FactoryGirl.create(:lesson, created_at: 1.day.ago, status: 'Published')
      digest = ChalklerDigest.new(chalkler)
      digest.new_lessons.count.should == 1
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
