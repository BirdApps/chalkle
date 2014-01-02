# encoding: UTF-8

class CalculateInitalRegionsForLessons < ActiveRecord::Migration
  class Channel < ActiveRecord::Base
  end
  class Region < ActiveRecord::Base
  end
  class Lesson < ActiveRecord::Base
    belongs_to :channel
    belongs_to :region
  end

  def up
    mappings = {
      'Wellington' => Region.find_by_name('Wellington'),
      'Waiheke Learning Community' => Region.find_by_name('Waiheke Island'),
      'Horowhenua' => Region.find_by_name('Horowhenua'),
      'Whānau' => Region.find_by_name('Wellington'),
      'Test Chalkle Channel' => Region.find_by_name('Wellington')
    }

    Lesson.all.each do |lesson|
      channel_name = lesson.channel ? lesson.channel.name : nil
      region = mappings[channel_name]
      if region
        lesson.region = region
        lesson.save
      end
    end
  end

  def down
  end
end
