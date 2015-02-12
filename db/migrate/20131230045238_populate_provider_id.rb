class PopulateProviderId < ActiveRecord::Migration
  class Lesson < ActiveRecord::Base
  end

  class ProviderLesson < ActiveRecord::Base
  end

  def up
  	Lesson.all.each do |lesson|
  		provider_lesson = ProviderLesson.where(lesson_id: lesson.id).first
  		if provider_lesson
  			lesson.update_attribute(:provider_id, provider_lesson.provider_id)
  		end
  	end
  end

  def down
  	Lesson.where("provider_id IS NOT NULL").all.each do |lesson|
  		ProviderLesson.create(lesson_id: lesson.id, provider_id: lesson.provider_id)
  	end
  end
end
