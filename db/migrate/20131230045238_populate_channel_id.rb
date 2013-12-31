class PopulateChannelId < ActiveRecord::Migration
  class Lesson < ActiveRecord::Base
  end

  class ChannelLesson < ActiveRecord::Base
  end

  def up
  	Lesson.all.each do |lesson|
  		channel_lesson = ChannelLesson.where(lesson_id: lesson.id).first
  		if channel_lesson
  			lesson.update_attribute(:channel_id, channel_lesson.channel_id)
  		end
  	end
  end

  def down
  	Lesson.where("channel_id IS NOT NULL").all.each do |lesson|
  		ChannelLesson.create(lesson_id: lesson.id, channel_id: lesson.channel_id)
  	end
  end
end
