require 'carrierwave'
require 'active_record'
require 'carrierwave/orm/activerecord'
require 'avatar_image_uploader'

module OmniAvatar
  class Avatar < ActiveRecord::Base
    mount_uploader :image, AvatarImageUploader

    belongs_to :owner, polymorphic: true

    attr_accessible :remote_image_url, :provider_name, :original_url

    validates_uniqueness_of :provider_name, scope: [:owner_id, :owner_type]
  end
end