# encoding: UTF-8

class CalculateInitalRegionsForLessons < ActiveRecord::Migration
  class Provider < ActiveRecord::Base
  end
  class Region < ActiveRecord::Base
  end
  class Lesson < ActiveRecord::Base
    belongs_to :provider
    belongs_to :region
  end

  def up
    mappings = {
      'Wellington' => Region.find_by_name('Wellington'),
      'Waiheke Learning Community' => Region.find_by_name('Waiheke Island'),
      'Horowhenua' => Region.find_by_name('Horowhenua'),
      'Whānau' => Region.find_by_name('Wellington'),
      'Test Chalkle Provider' => Region.find_by_name('Wellington')
    }

    Lesson.all.each do |lesson|
      provider_name = lesson.provider ? lesson.provider.name : nil
      region = mappings[provider_name]
      if region
        lesson.region = region
        lesson.save
      end
    end
  end

  def down
  end
end
