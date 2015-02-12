require 'provider_photo_uploader'

class ProviderPhoto < ActiveRecord::Base
  mount_uploader :image, ProviderPhotoUploader

  belongs_to :provider

  attr_accessible :image, :as => :admin
end