# encoding: utf-8

class ChannelPhotoUploader < ChalkleBaseUploader
  process :resize_to_fill => [360, 240]
end
