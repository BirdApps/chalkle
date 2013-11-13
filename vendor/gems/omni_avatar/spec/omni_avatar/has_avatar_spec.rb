require 'spec_helper'
require 'omni_avatar/has_avatar'

describe OmniAvatar::HasAvatar do
  subject {
    owner = AvatarOwner.new
    owner.avatars = double(:avatars)
    owner
  }

  def avatar_from(provider_name)
    double("#{provider_name} avatar", provider_name: provider_name)
  end

  context "mixed into a model" do
    let(:avatar) { avatar_from('facebook') }

    before :each do
      @klass = stub_const('AvatarOwner', Class.new)
      @klass.stub(has_many: nil)
      @klass.module_eval do
        attr_accessor :avatars
        include OmniAvatar::HasAvatar
      end
    end

    context "adding avatars" do
      it "adds an avatar to the collection of avatars" do
        subject.avatars.should_receive(:<<).with(avatar)
        subject.add_avatar avatar
      end
    end
  end
end