#require 'spec_helper'
#require 'omni_avatar/null_avatar'
#require 'omni_avatar/has_avatar'
#require 'omni_avatar/avatar'
#require 'omni_avatar/providers/place_hold_it'
#
#class User < ActiveRecord::Base
#  include OmniAvatar::HasAvatar
#end
#
#describe "adding and removing avatars from a user" do
#  let(:user)             { User.new }
#  let(:provider)         { OmniAvatar::Providers::PlaceHoldIt.new }
#  let(:user_data)        { "some data" }
#
#  it "should have no avatar by default" do
#    expect(user.avatar).to be_a OmniAvatar::NullAvatar
#    expect(user.avatar).to be_nil
#    expect(user.avatar).to be_false
#    expect(user.avatar.url).to be_nil
#  end
#
#  pending "should add an avatar and persist it" do
#    user.add_avatar provider.build_avatar(user_data)
#
#    expect(user.avatar).to be_a OmniAvatar::Avatar
#    expect(user.avatar.url).to eql expected_url
#  end
#end