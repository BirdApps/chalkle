require 'spec_helper'

describe Channel do
  it { should have_many(:admin_users).through(:channel_admins) }
  it { should have_many(:chalklers).through(:channel_chalklers) }
  it { should have_many(:lessons).through(:channel_lessons) }
  it { should have_many(:bookings).through(:lessons) }
  it { should have_many(:categories).through(:channel_categories) }

  it { should validate_presence_of :name }
  it { should validate_presence_of :url_name }
  it { should validate_presence_of :teacher_percentage }
  it { should validate_presence_of :channel_percentage }

  specify { FactoryGirl.build(:channel).should be_valid }

  let(:channel) { FactoryGirl.create(:channel) }

  describe "default values" do

  	it "should set default teacher percentage" do
  		channel.teacher_percentage.should == 0.75
  	end

  	it "should set default channel percentage" do
  		channel.channel_percentage.should == 0.125
  	end

  	it "should set default chalkle percentage" do
  		channel.chalkle_percentage.should == 0.125
  	end

  end

  describe "validation" do

  	it "should not allow teacher percentage greater than 1" do
  		channel.teacher_percentage = 1.2
  		channel.should_not be_valid
  	end

  	it "should not allow channel percentage greater than 1" do
  		channel.channel_percentage = 1.2
  		channel.should_not be_valid
  	end

  	it "should not allow sum of percentages greater than 0.875" do
  		channel.channel_percentage = 0.6
  		channel.teacher_percentage = 0.4
  		channel.should_not be_valid
  	end

  end

  describe ".select_options" do
  	let(:chalkler) { FactoryGirl.create(:chalkler)}
    let(:channel1) { FactoryGirl.create(:channel, name: "channel1") }
  	let(:channel2) { FactoryGirl.create(:channel, name: "channel2") }

    before do
      chalkler.channels << channel1
      chalkler.channels << channel2
    end

  	it "should provide an array of options that can be used in dropdowns" do
  		required_array = [['channel1', channel1.id],['channel2', channel2.id]]
  		Channel.select_options(chalkler.channels).should eq(required_array)
  	end
  end

  describe "email validations" do
    it "should not allow email without @" do
    	channel = Channel.create(name: "test", email: "abs123")
    	channel.should_not be_valid
    end

    it "should not allow with @ but no ." do
    	channel = Channel.create(name: "test", email: "abs@123")
    	channel.should_not be_valid
    end
  end

  describe "Performance calculation methods, section: chalklers" do
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
      @channel.new_chalklers(2,0).should == 1
    end

    it "calculates the number of active members" do
      @channel.percent_active(0).should == 60
    end
  end

  describe "Performance calculation methods, section: classes" do
    before do
      @channel = FactoryGirl.create(:channel)
      @chalkler = FactoryGirl.create(:channel, channel_percentage: 0.2, teacher_percentage: 0.5)
      (1..5).each do |i|
        lesson = FactoryGirl.create(:lesson, meetup_id: i*11111111, name: "test class #{i}", cost: i*10, teacher_cost: i*5, teacher_payment: i*5, start_at: 2.days.ago, status: "Published", max_attendee: 10)
        lesson.channels << @channel
        booking = FactoryGirl.create(:booking, lesson_id: lesson.id, guests: i-1, chalkler_id: @chalkler.id, paid: true, status: "yes")
        if (i == 5)
          FactoryGirl.create(:payment, booking_id: booking.id, total: i*10*1.15, reconciled: true, cash_payment: true)
        else
          FactoryGirl.create(:payment, booking_id: booking.id, total: i*10*1.15, reconciled: true, cash_payment: false)
        end
    end

    it "calculates total revenue" do
      @channel.total_revenue(3,0).should == 150        
    end

    it "calculates total turnover" do
      @channel.financial_stats(6.days.ago.to_date,7.days).turnover.should == 150
    end

    it "calculates total cost from lessons" do
      @channel.total_cost(3,0).should == 125  
    end

    it "calculates total cost" do
      @channel.financial_stats(6.days.ago.to_date,7.days).cost.should == 125
    end

    it "calculates new and repeat lessons from classes run" do
      lesson2 = FactoryGirl.create(:lesson, meetup_id: 1234567, name: "test class 1", status: "Published", start_at: 50.days.ago)
      lesson2.channels << @channel
      @channel.classes_run(3,0).should == [4,1]
      lesson2.destroy  
    end

    it "calculates total attendee" do
      @channel.attendee(3,0).should == 15
    end

    it "calculates fill fraction" do
      @channel.fill_fraction(3,0).should == 30
    end

    it "calculates number of paid classes" do
      lesson2 = FactoryGirl.create(:lesson, meetup_id: 1234567, name: "test class 1", status: "Published", start_at: 2.days.ago, cost: 0)
      lesson2.channels << @channel
      @channel.classes_pay(3,0).should == 5
    end
  end

end
