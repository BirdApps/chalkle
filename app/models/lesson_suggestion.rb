class LessonSuggestion < ActiveRecord::Base
  attr_accessible :description, :name, :category_id, :channel_ids

  belongs_to :category
  has_many :channel_lesson_suggestions
  has_many :channels, :through => :channel_lesson_suggestions

  validates :name, :description, :presence => true
end
