class CalculateCachedCostsForLessons < ActiveRecord::Migration
  def up
    Lesson.all.each do |lesson|
      lesson.cached_channel_fee = lesson.channel_fee
      lesson.cached_chalkle_fee = lesson.chalkle_fee
      lesson.save validate: false
    end
  end

  def down
  end
end
