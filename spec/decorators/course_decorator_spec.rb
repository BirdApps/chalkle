require 'spec_helper'

describe CourseDecorator do
  let(:course) { FactoryGirl.create(:course).decorate }

  describe ".join_chalklers" do
    it "returns generic text when attendence is less than 2" do
      FactoryGirl.create(:booking, status: 'yes', guests: 0, course: course)
      course.join_chalklers.should == 'Join this class'
    end

    it "formats text when attendence is more than 1" do
      2.times { FactoryGirl.create(:booking, status: 'yes', guests: 0, course: course) }
      course.join_chalklers.should == 'Join 2 other chalklers'
    end
  end

  describe ".account" do
    it "should retrieve the correct account number" do
      channel = FactoryGirl.create(:channel, account: "12-1234-1234567-00")
      course.channel = channel
      course.account.should == channel.account
    end

    it "should retrieve the default message when no bank account number exists" do
      course.channel = FactoryGirl.create(:channel)
      course.account.should == "Please email accounts@chalkle.com for payment instructions"
    end
  end

  describe ".formatted_price" do
    it "displays 'Free' when the course has no cost" do
      course.cost = 0
      course.formatted_price.should == 'Free'
    end

    it "formats price when the course is not free" do
      course.cost = 5.0
      course.formatted_price.should == '$5.00'
    end
  end

  describe ".url" do
    before do
      @course = FactoryGirl.create(:course, meetup_url: 'http://meetup.com')
    end

    it "returns rails path when channel is local" do
      channel = FactoryGirl.create(:channel, url_name: '')
      @course.channel = channel
      expect(@course.decorate.url).to include("/channels/#{channel.id}/classes/#{@course.id}")
    end
  end

end
