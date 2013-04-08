require 'spec_helper'

describe "Chalkler_stats" do

  describe "Membership Statistics" do

    before do 
      @channel = FactoryGirl.create(:channel)
      @lesson1 = FactoryGirl.create(:lesson, name: "test 1")
      @lesson2 = FactoryGirl.create(:lesson, name: "test 2")
      (1..5).each do |i|
        chalkler = FactoryGirl.create(:chalkler, meetup_id: i*11111111, email: "test#{i}@gmail.com", created_at: 1.year.ago)
        chalkler.channels << @channel
        FactoryGirl.create(:booking, lesson_id: @lesson1.id, chalkler_id: chalkler.id, created_at: i.months.ago)
        FactoryGirl.create(:booking, lesson_id: @lesson2.id, chalkler_id: chalkler.id, created_at: i.months.ago)
      end    
    end

    it "calculates the number of new members" do
      chalkler2 = FactoryGirl.create(:chalkler, meetup_id: 1234565, email: "test@gmail.com", created_at: 1.day.ago)
      chalkler2.channels << @channel
      @channel.chalkler_stats(7.days.ago,7.days).new_chalklers.should == 1
    end

    it "calculates the number of active members" do
      @channel.chalkler_stats(7.days.ago,7.days).percent_active.should == 60
    end 
  end

end
