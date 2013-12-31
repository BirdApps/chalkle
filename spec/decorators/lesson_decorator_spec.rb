require 'spec_helper'

describe LessonDecorator do
  let(:lesson) { FactoryGirl.create(:lesson).decorate }

  describe ".join_chalklers" do
    it "returns generic text when attendence is less than 2" do
      FactoryGirl.create(:booking, status: 'yes', guests: 0, lesson: lesson)
      lesson.join_chalklers.should == 'Join this class'
    end

    it "formats text when attendence is more than 1" do
      2.times { FactoryGirl.create(:booking, status: 'yes', guests: 0, lesson: lesson) }
      lesson.join_chalklers.should == 'Join 2 other chalklers'
    end
  end

  describe ".account" do
    it "should retrieve the correct account number" do
      channel = FactoryGirl.create(:channel, account: "12-1234-1234567-00")
      lesson.channel = channel
      lesson.account.should == channel.account
    end

    it "should retrieve the default message when no bank account number exists" do
      lesson.channel = FactoryGirl.create(:channel)
      lesson.account.should == "Please email accounts@chalkle.com for payment instructions"
    end
  end

  describe ".formatted_price" do
    it "displays 'Free' when the lesson has no cost" do
      lesson.cost = 0
      lesson.formatted_price.should == 'Free'
    end

    it "formats price when the lesson is not free" do
      lesson.cost = 5.0
      lesson.formatted_price.should == '$5.00'
    end
  end

  describe ".url" do
    before do
      @lesson = FactoryGirl.create(:lesson, meetup_url: 'http://meetup.com')
    end

    it "returns meetup link when channel on meetup" do
      @lesson.channel = FactoryGirl.create(:channel, url_name: 'sixdegrees')
      @lesson.decorate.url.should == 'http://meetup.com'
    end

    it "returns rails path when channel is local" do
      channel = FactoryGirl.create(:channel, url_name: '')
      @lesson.channel = channel
      @lesson.decorate.url.should include("/channels/#{channel.id}/classes/#{@lesson.id}")
    end
  end

end
