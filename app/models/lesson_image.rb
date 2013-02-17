class LessonImage < ActiveRecord::Base
  attr_accessible :title, :pointsize

  belongs_to :lesson

  validates_presence_of :title
  validates_presence_of :pointsize
end
