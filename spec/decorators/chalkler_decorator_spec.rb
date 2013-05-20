require 'spec_helper'

describe ChalklerDecorator do
  describe ".channel_links" do
    before do
      @chalkler = FactoryGirl.create(:chalkler)
      @chalkler.channels << FactoryGirl.create(:channel, name: 'xyz', url_name: 'xyz')
      @chalkler.channels << @channel = FactoryGirl.create(:channel, name: 'xyz', url_name: '')
    end

    it "creates a linked list of channels" do
      @chalkler.decorate.channel_links.should == "<a href=\"http://www.meetup.com/xyz/events/calendar/?scroll=true\" style=\"\">xyz</a> | <a href=\"http://localhost:3000/channels/#{@channel.id}\" style=\"\">xyz</a>"
    end

    it 'adds custom css' do
      @chalkler.decorate.channel_links('color: #000;').should == "<a href=\"http://www.meetup.com/xyz/events/calendar/?scroll=true\" style=\"color: #000;\">xyz</a> | <a href=\"http://localhost:3000/channels/#{@channel.id}\" style=\"color: #000;\">xyz</a>"
    end

  end
end
