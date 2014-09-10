# encoding: utf-8
require 'chalkle_base_image_uploader'

class ChannelHeroUploader < ChalkleBaseImageUploader

   process :resize_to_fill => [2400, 2400]

  version :blurred do 
    process :blur => 20
  end

end
