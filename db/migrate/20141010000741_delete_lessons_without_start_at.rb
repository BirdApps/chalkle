class DeleteLessonsWithoutStartAt < ActiveRecord::Migration
  def up
    Lesson.where( start_at: nil ).destroy_all
  end

  def down
    ActiveRecord::IrreversableMigration
  end
end
