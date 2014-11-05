require 'spec_helper'

describe ChalklerDecorator do
  describe ".channel_links" do
    before do
      @chalkler = FactoryGirl.create(:chalkler)
      @chalkler.channels << FactoryGirl.create(:channel, name: 'Meetup', url_name: 'meetup', visible: true)
      @chalkler.channels << @channel = FactoryGirl.create(:channel, name: 'Local', url_name: '', visible: true)
    end

    it "links to a local channel" do
      @chalkler.decorate.channel_links.should include('Local', @channel.id.to_s)
    end

    it 'adds custom css' do
      @chalkler.decorate.channel_links('color: #000;').should include('color: #000;')
    end

    it "doesn't display hidden channels" do
      @channel.update_attribute :visible, false
      @chalkler.decorate.channel_links.should_not include('Local', "channels/#{@channel.id}")
    end
  end
end
