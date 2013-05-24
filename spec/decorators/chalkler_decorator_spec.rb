require 'spec_helper'

describe ChalklerDecorator do
  describe ".channel_links" do
    before do
      @chalkler = FactoryGirl.create(:chalkler)
      @chalkler.channels << FactoryGirl.create(:channel, name: 'Meetup', url_name: 'meetup')
      @chalkler.channels << @channel = FactoryGirl.create(:channel, name: 'Local', url_name: '')
    end

    it "links to a Meetup based channel" do
      @chalkler.decorate.channel_links.should include('Meetup', 'meetup')
    end

    it "links to a local channel" do
      @chalkler.decorate.channel_links.should include('Local', "channels/#{@channel.id}")
    end

    it 'adds custom css' do
      @chalkler.decorate.channel_links('color: #000;').should include('color: #000;')
    end
  end
end
