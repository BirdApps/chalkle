class RemoveCourseImage < ActiveRecord::Migration
  def up
    drop_table :course_images
  end

  def down
    ActiveRecord::IrreversibleMigration
  end
end
