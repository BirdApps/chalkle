# encoding: utf-8
require 'chalkle_base_image_uploader'

class ProviderLogoUploader < ChalkleBaseImageUploader

  process :resize_to_fill => [400, 400]

end