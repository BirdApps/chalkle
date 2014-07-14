require 'spec_helper'

describe VenueImporter do
  let(:results) { MeetupApiStub::venue_response }
  let(:channel) { FactoryGirl.create(:channel, name: 'Wellington') }
  let(:importer) { VenueImporter.new(channel) }

  describe 'initialization' do
    it "assigns a channel for the import" do
      expect(importer.instance_eval{ @channel }).to be channel
    end
  end

  describe "#update_records" do
    before do
      importer.results = [results]
      importer.update_records
    end

    it "creates a venue from imported hash" do
      expect(Venue.where{name == 'Venue'}.exists?).to be true
    end

    it "creates a city from imported hash" do
      expect(City.where{name == 'Wellington'}.exists?).to be true
    end
  end
end
