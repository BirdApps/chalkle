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
      img.blur "#{radius/1.5}x#{radius}"
      img.modulate "92,125,100"
      img = yield(img) if block_given?
      img
    end
  end

  def average_color
    @averagecolor ||= manipulate! do |img|
      img.scale "1x1\!"
      /^srgb\((\d+)\,(\d+)\,(\d+)\)$/ =~ img["%[pixel:s]"]
      return "##{ $1.to_i.to_s(16) }#{ $2.to_i.to_s(16) }#{ $3.to_i.to_s(16) }"
    end
  end


end
