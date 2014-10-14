# encoding: utf-8
class AvatarUploader < ChalkleBaseImageUploader
  process :resize_to_fill => [256, 256]
end
