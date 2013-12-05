# encoding: utf-8

class ChannelLogoUploader < ChalkleBaseImageUploader
  process :resize_to_fill => [165, 165]
end
