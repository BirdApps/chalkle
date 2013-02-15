class LessonCategory < ActiveRecord::Base
  validates_uniqueness_of :category_id, :scope => :lesson_id
  belongs_to :lesson
  belongs_to :category
end
