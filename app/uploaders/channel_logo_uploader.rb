# encoding: utf-8
require 'chalkle_base_image_uploader'

class ChannelLogoUploader < ChalkleBaseImageUploader
  process :resize_to_fill => [165, 165]
end
