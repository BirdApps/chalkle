class GroupLesson < ActiveRecord::Base
  validates_uniqueness_of :lesson_id, :scope => [:group_id]
  belongs_to :group
  belongs_to :lesson
end
