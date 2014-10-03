# encoding: utf-8
require 'chalkle_base_image_uploader'

class ChannelHeroUploader < ChalkleBaseImageUploader

  after :store, :cache_average_color


  def cache_average_color(file)
    @model.update_column :average_hero_color, @model.hero.average_color
  end


   process :resize_to_fill => [2400, 2400]

  version :blurred do 
    process :blur => 15
  end


  def extension_white_list
    %w(jpg jpeg png)
  end


end
