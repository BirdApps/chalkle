# encoding: utf-8
require 'carrierwave'

# TODO: This is currently Chalkle specific. Make this configurable in OmniAvatar
UPLOADER_BASE_CLASS = if defined?(ChalkleBaseUploader)
  ChalkleBaseUploader
else
  class AvatarBaseUploader < CarrierWave::Uploader::Base
    include CarrierWave::RMagick
    storage :file
    def store_dir
      "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{partition}/#{model.id}"
    end

    def partition
      "#{model.id.to_s[-3..-1]}/#{model.id.to_s[-6..-4]}"
    end
  end
  AvatarBaseUploader
end

class AvatarImageUploader < UPLOADER_BASE_CLASS
  process :resize_to_fill => [100,100]
end
