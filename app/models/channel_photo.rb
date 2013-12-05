require 'carrierwave'

class ChannelPhoto < ActiveRecord::Base
  mount_uploader :image, ChannelPhotoUploader

  belongs_to :channel

  attr_accessible :image, :as => :admin
end