class RemoveColumnTeacherBioFromCourse < ActiveRecord::Migration
  def up
    remove_column :courses, :teacher_bio
  end

  def down
    add_column :courses, :teacher_bio, :string
  end
end