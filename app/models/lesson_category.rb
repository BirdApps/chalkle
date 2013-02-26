class LessonCategory < ActiveRecord::Base
  attr_accessible :lesson_id, :category_id
  validates_uniqueness_of :category_id, :scope => :lesson_id
  belongs_to :lesson
  belongs_to :category
end
