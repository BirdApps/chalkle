require 'spec_helper'

describe LessonDecorator do
  let(:lesson) { FactoryGirl.create(:lesson).decorate }

  describe ".channel_list" do
    it "returns nil when a lesson has no channels" do
      lesson.channel_list.should be_nil
    end

    it "formats a single channel" do
      lesson.channels << FactoryGirl.create(:channel, name: 'Wellington')
      lesson.channel_list.should == 'Wellington'
    end

    it "formats multiple channels" do
      lesson.channels << FactoryGirl.create(:channel, name: 'Wellington')
      lesson.channels << FactoryGirl.create(:channel, name: 'Whanau')
      lesson.channel_list.should == 'Wellington, Whanau'
    end
  end

  describe ".category_list" do
    it "returns nil when a lesson has no categories" do
      lesson.category_list.should be_nil
    end

    it "returns a formated list of categories" do
      ['one', 'two', 'three'].each do |c|
        lesson.categories << FactoryGirl.create(:category, name: c)
      end
      lesson.category_list.should == 'In One, Two, Three'
    end
  end

  describe ".join_chalklers" do
    it "returns generic text when attendence is less than 2" do
      FactoryGirl.create(:booking, status: 'yes', guests: 0, lesson: lesson)
      lesson.join_chalklers.should == 'Join this chalkle'
    end

    it "formats text when attendence is more than 1" do
      2.times { FactoryGirl.create(:booking, status: 'yes', guests: 0, lesson: lesson) }
      lesson.join_chalklers.should == 'Join 2 other chalklers'
    end
  end

  describe "account number" do
    it "should retrieve the correct account number" do
      channel = FactoryGirl.create(:channel, account: "12-1234-1234567-00")
      lesson.channels << channel
      lesson.account.should == channel.account
    end

    it "should retrieve the default message when no bank account number exists" do
      channel = FactoryGirl.create(:channel)
      lesson.channels << channel
      lesson.account.should == "Please email accounts@chalkle.com for payment instructions"
    end
  end


end
