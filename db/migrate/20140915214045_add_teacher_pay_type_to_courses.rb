class AddTeacherPayTypeToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :teacher_pay_type, :string
  end
end
