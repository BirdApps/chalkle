# encoding: utf-8
require 'carrierwave'
require 'external_carrierwave_base'

class AvatarImageUploader < ExternalCarrierwaveImageBase
  process :resize_to_fill => [100,100]
end
