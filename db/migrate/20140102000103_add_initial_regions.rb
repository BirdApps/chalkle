class AddInitialRegions < ActiveRecord::Migration
  class Region < ActiveRecord::Base
    attr_accessible :name
  end

  def up
    ['Wellington', 'Horowhenua', 'Waiheke Island'].each do |name|
      Region.create(name: name)
    end
  end

  def down
    Region.delete_all
  end
end
