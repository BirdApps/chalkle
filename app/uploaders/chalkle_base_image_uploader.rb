# encoding: utf-8
require 'chalkle_base_uploader'

class ChalkleBaseImageUploader < ChalkleBaseUploader
  include CarrierWave::MiniMagick

  def extension_white_list
    %w(jpg jpeg gif png)
  end
end
