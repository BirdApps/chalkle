class SetUrlNameForRegions < ActiveRecord::Migration
  class Region < ActiveRecord::Base
  end

  def up
    Region.all.each do |region|
      region.url_name = region.name.split(' ').first.downcase
      region.save
    end
  end

  def down
  end
end
