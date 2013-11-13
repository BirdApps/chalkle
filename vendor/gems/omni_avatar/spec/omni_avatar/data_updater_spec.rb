require 'omni_avatar/data_updater'
require 'omni_avatar/avatar_collection'

module OmniAvatar
  class ConcreteCollection < Array
    include AvatarCollection
  end

  describe DataUpdater do
    let(:data_parser) { double(:data_parser) }
    let(:data)        { {'some' => 'data'} }
    let(:url)         { 'http://www.some_url.com' }
    let(:collection)  { ConcreteCollection.new }
    subject { DataUpdater.new(data_parser: data_parser, provider_name: 'some_provider') }

    describe "#update_from_data" do
      context "with valid data" do
        before do
          data_parser.should_receive(:url_from_data).with(data).and_return(url)
        end

        it "adds a new avatar to the collection" do
          subject.update_from_data collection, data

          collection.length.should == 1
          collection.first.remote_image_url.should == url
          collection.first.original_url.should == url
          collection.first.provider_name.should == 'some_provider'
        end

        it "doesn't re-add an avatar with the same url to the collection" do
          existing = Avatar.new(original_url: url, provider_name: 'some_provider')
          collection << existing

          subject.update_from_data collection, data

          collection.length.should == 1
          collection.should == [existing]
        end
      end
    end
  end
end