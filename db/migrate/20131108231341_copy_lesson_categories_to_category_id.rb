class CopyLessonCategoriesToCategoryId < ActiveRecord::Migration
  class Lesson < ActiveRecord::Base
    has_many :lesson_categories
    has_many :categories, :through => :lesson_categories
  end

  def up
    Lesson.all.each do |lesson|
      category = lesson.categories.first
      if category
        lesson.update_attribute(:category_id, category.id)
      end
    end
  end

  def down
  end
end
