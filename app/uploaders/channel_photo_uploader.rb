# encoding: utf-8
class ChannelPhotoUploader < ChalkleBaseImageUploader
  process :resize_to_fill => [360, 240]
end
