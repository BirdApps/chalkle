class AddTeacherPaymentToLesson < ActiveRecord::Migration
  def up
  	add_column :lessons, :teacher_payment, :decimal, :default => nil, :precision => 8, :scale => 2

  	Lesson.reset_column_information

    Lesson.all.each { |l| l.update_attribute :teacher_payment, nil }
  end

  def down
  	remove_column :lessons, :teacher_payment
  end
end
