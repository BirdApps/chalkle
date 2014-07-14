class RenameForeignKeyLessonsRegionIdFkOnCourses < ActiveRecord::Migration
  def up
    remove_foreign_key :courses, :name => :lessons_region_id_fk
    add_foreign_key :courses, :regions, name: 'courses_region_id_fk'
  end

  def down
    ActiveRecord::IrreversibleMigration
  end
end
