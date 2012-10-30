class GroupLesson < ActiveRecord::Base
  belongs_to :group
  belongs_to :lesson
end
