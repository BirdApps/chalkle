require 'spec_helper'

describe ChalklerDecorator do
  describe ".meetup_channels" do
    before do
      @chalkler = ChalklerDecorator.decorate(FactoryGirl.create(:chalkler))
      2.times { @chalkler.channels << FactoryGirl.create(:channel, name: 'xyz', url_name: 'xyz') }
    end

    it "creates a linked list of channels" do
      @chalkler.meetup_channels.should == '<a href="http://www.meetup.com/xyz/events/calendar/?scroll=true" style="">xyz</a> | <a href="http://www.meetup.com/xyz/events/calendar/?scroll=true" style="">xyz</a>'
    end

    it 'adds custom css' do
      @chalkler.meetup_channels('color: #000;').should == '<a href="http://www.meetup.com/xyz/events/calendar/?scroll=true" style="color: #000;">xyz</a> | <a href="http://www.meetup.com/xyz/events/calendar/?scroll=true" style="color: #000;">xyz</a>'
    end

  end
end
