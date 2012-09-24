class Lesson < ActiveRecord::Base
  attr_accessible :title, :body, :category_id, :teacher_id, :kind, :title, :doing, :learn, :skill, :skill_note, :bring, :charge, :cost, :book, :note, :start, :end, :link

  belongs_to :category
  belongs_to :teacher
end
