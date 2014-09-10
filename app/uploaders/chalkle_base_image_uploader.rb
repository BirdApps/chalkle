# encoding: utf-8
require 'chalkle_base_uploader'

class ChalkleBaseImageUploader < ChalkleBaseUploader
  include CarrierWave::MiniMagick

  def extension_white_list
    %w(jpg jpeg gif png)
  end


protected

  def blur(radius=16)
    manipulate! do |img|
      img.blur "0x#{radius}"
      img.modulate "92,125,100"
      img = yield(img) if block_given?
      img
    end
  end


end
