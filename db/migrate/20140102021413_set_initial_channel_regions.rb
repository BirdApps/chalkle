# encoding: UTF-8

class SetInitialChannelRegions < ActiveRecord::Migration
  class Channel < ActiveRecord::Base
  end
  class Region < ActiveRecord::Base
  end
  class ChannelRegion < ActiveRecord::Base
    attr_accessible :channel_id, :region_id
  end

  def up
    mappings = {
      'Wellington' => Region.find_by_name('Wellington'),
      'Waiheke Learning Community' => Region.find_by_name('Waiheke Island'),
      'Horowhenua' => Region.find_by_name('Horowhenua'),
      'Whānau' => Region.find_by_name('Wellington'),
      'Test Chalkle Channel' => Region.find_by_name('Wellington')
    }

    Channel.all.each do |channel|
      region = mappings[channel.name]
      if region
        ChannelRegion.create(channel_id: channel.id, region_id: region.id)
      end
    end

  end

  def down
    ChannelRegion.delete_all
  end
end
