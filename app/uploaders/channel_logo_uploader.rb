# encoding: utf-8
require 'chalkle_base_image_uploader'

class ChannelLogoUploader < ChalkleBaseImageUploader

  include CarrierWave::MiniMagick

  process :resize_to_fill => [165, 165]

  version :blurred do 
    process :blur => 10
  end

  private

  def blur(radius=16)
    manipulate! do |img|
      img.gaussian_blur radius
      img = yield(img) if block_given?
      img
    end
  end

end
