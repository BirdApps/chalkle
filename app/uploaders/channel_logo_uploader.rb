# encoding: utf-8

class ChannelLogoUploader < ChalkleBaseUploader
  process :resize_to_fill => [165, 165]
end
