# encoding: UTF-8

class SetInitialProviderRegions < ActiveRecord::Migration
  class Provider < ActiveRecord::Base
  end
  class Region < ActiveRecord::Base
  end
  class ProviderRegion < ActiveRecord::Base
    attr_accessible :provider_id, :region_id
  end

  def up
    mappings = {
      'Wellington' => Region.find_by_name('Wellington'),
      'Waiheke Learning Community' => Region.find_by_name('Waiheke Island'),
      'Horowhenua' => Region.find_by_name('Horowhenua'),
      'Whānau' => Region.find_by_name('Wellington'),
      'Test Chalkle Provider' => Region.find_by_name('Wellington')
    }

    Provider.all.each do |provider|
      region = mappings[provider.name]
      if region
        ProviderRegion.create(provider_id: provider.id, region_id: region.id)
      end
    end

  end

  def down
    ProviderRegion.delete_all
  end
end
