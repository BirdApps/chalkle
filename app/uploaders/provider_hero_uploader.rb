# encoding: utf-8
require 'chalkle_base_image_uploader'

class ProviderHeroUploader < ChalkleBaseImageUploader

  after :cache, :cache_average_color

  version :blurred do 
    process :blur => 25
  end

  def cache_average_color(file)
    model.update_column :average_hero_color, model.hero.average_color
  end

  def extension_white_list
    %w(jpg jpeg png)
  end

  def store_dir
    "system/uploads/#{Rails.env}/channel/#{mounted_as}/#{model.id}"
  end


end
