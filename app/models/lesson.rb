class Lesson < ActiveRecord::Base
  attr_accessible :title, :body, :category_id, :kind, :title, :doing, :learn, :skill, :skill_note, :teacher_name, :teacher_qualification, :bring, :charge, :cost, :book, :note, :start, :end, :link
end
