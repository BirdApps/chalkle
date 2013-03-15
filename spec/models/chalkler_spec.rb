require 'spec_helper'

describe Chalkler do

  it { should have_many(:channels).through(:channel_chalklers) }

  describe '.email_frequency_select_options' do
    it "provides an array of options that can be used in select dropdowns" do
      stub_const("Chalkler::EMAIL_FREQUENCY_OPTIONS", %w(yes no))

      required_array = [%w(Yes yes), %w(No no)]
      Chalkler.email_frequency_select_options.should eq(required_array)
    end
  end

  describe "creation" do
    it "should have a valid factory" do
      FactoryGirl.build(:chalkler).should be_valid
    end

    it { should validate_uniqueness_of :meetup_id }
    it { should validate_uniqueness_of :email }

    it "should validate GST numbers" do
      FactoryGirl.build(:chalkler, gst: "ash 8765").should_not be_valid
      FactoryGirl.build(:chalkler, gst: "23-345 8765").should be_valid
    end
  end

  describe ".create_from_meetup_hash" do
    let(:result) { MeetupApiStub.chalkler_response }
    let(:channel) { FactoryGirl.create(:channel) }

    it "saves valid chalkler" do
      Chalkler.create_from_meetup_hash(result, channel)
      Chalkler.find_by_meetup_id(12345678).should be_valid
    end

    it "updates an existing chalkler" do
      chalkler = FactoryGirl.create(:chalkler, meetup_id: 12345678, name: "Jim Smith")
      Chalkler.create_from_meetup_hash(result, channel)
      chalkler.reload.name.should == "Caitlin Oscars"
    end

    it "saves valid #meetup_data" do
      Chalkler.create_from_meetup_hash(result, channel)
      chalkler = Chalkler.find_by_meetup_id 12345678
      chalkler.meetup_data["id"].should == 12345678
      chalkler.meetup_data["name"].should == "Caitlin Oscars"
    end
  end

  describe "#set_from_meetup_data" do
    let(:result) { MeetupApiStub::chalkler_response }
    let(:channel) { FactoryGirl.create(:channel) }

    it "saves correct created_at value" do
      Chalkler.create_from_meetup_hash(result, channel)
      chalkler = Chalkler.find_by_meetup_id 12345678
      chalkler.created_at.to_time.to_i.should == 1346658337
    end
  end

  describe "Performance calculation methods" do
    before do 
      @channel = FactoryGirl.create(:channel)
      @lesson = FactoryGirl.create(:lesson)
      (1..5).each do |i|
        chalkler = FactoryGirl.create(:chalkler, meetup_id: i*11111111, email: "test#{i}@gmail.com", created_at: 1.year.ago)
        chalkler.channels << @channel
        FactoryGirl.create(:booking, lesson_id: @lesson.id, chalkler_id: chalkler.id, created_at: i.months.ago)
      end    
    end
    it "calculates the number of new members" do
      chalkler2 = FactoryGirl.create(:chalkler, meetup_id: 1234565, email: "test@gmail.com", created_at: 1.day.ago)
      chalkler2.channels << @channel
      Chalkler.new_chalklers(2,0,@channel.id).should == 1
    end

    it "calculates the number of active members" do
      Chalkler.percent_active(0.weeks.ago,@channel.id).should == 60
    end
  end
end
