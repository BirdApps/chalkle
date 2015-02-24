class RemoveCourseSkill < ActiveRecord::Migration
  def up
    remove_column :courses, :course_skill
  end

  def down
    ActiveRecord::IrreversibleMigration
  end
end
