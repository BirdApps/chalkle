require 'spec_helper'
require 'omni_avatar/avatar_collection'

describe OmniAvatar::AvatarCollection do
  class DummyActiveRecordAssociation < Array
    def destroy_records(records)
      records.each do |record|
        delete(record)
      end
    end
  end

  class TestAvatarCollection < DummyActiveRecordAssociation
    include OmniAvatar::AvatarCollection
  end

  def avatar_from(provider_name)
    double("#{provider_name} avatar", provider_name: provider_name)
  end

  subject { TestAvatarCollection.new }

  context "adding avatars" do
    it "adds an avatar to the collection of avatars" do
      subject << (facebook = avatar_from('facebook'))
      subject.should include(facebook)
    end

    context "when avatar from that provider already exists" do
      it "replaces existing avatar" do
        facebook1 = avatar_from('facebook')
        facebook2 = avatar_from('facebook')

        subject << facebook1
        facebook1.should_receive :destroy
        subject << facebook2
      end
    end

    context "when an avatar from another provider exists" do
      it "adds this avatar too"
    end
  end
end