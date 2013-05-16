require 'spec_helper'

describe VenueImporter do
  let(:results) { MeetupApiStub::venue_response }
  let(:channel) { FactoryGirl.create(:channel, name: 'Wellington') }
  let(:importer) { VenueImporter.new(channel) }

  describe 'initialization' do
    it "assigns a channel for the import" do
      importer.instance_eval{ @channel }.should == channel
    end
  end

  describe "#update_records" do
    before do
      importer.results = [results]
      importer.update_records
    end

    it "creates a venue from imported hash" do
      Venue.where{name == 'Venue'}.exists?.should be_true
    end

    it "creates a city from imported hash" do
      City.where{name == 'Wellington'}.exists?.should be_true
    end
  end
end
