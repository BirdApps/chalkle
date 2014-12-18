require 'spec_helper'

describe ChalklerDecorator do
  describe ".channel_links" do
    let(:channels) {[
      FactoryGirl.create(:channel, name: 'Meetup', url_name: 'meetup', visible: true),
      FactoryGirl.create(:channel, name: 'Local', url_name: '', visible: true)
    ]}
    let(:chalkler) { 
      FactoryGirl.create(:chalkler, :channels => channels)
    }

    it "links to a local channel" do
      expect(chalkler.decorate.channel_links).to include('Local')
    end

    it "doesn't display hidden channels" do
      chalkler.channels.last.update_attribute :visible, false
      expect(chalkler.decorate.channel_links).not_to include('Local', "channels/#{chalkler.channels.last.id}")
    end
  end
end
