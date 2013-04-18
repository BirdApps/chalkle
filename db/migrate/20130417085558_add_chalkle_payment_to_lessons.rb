class AddChalklePaymentToLessons < ActiveRecord::Migration
  def up
  	add_column :lessons, :chalkle_payment, :decimal, :default => nil, :precision => 8, :scale => 2

  	Lesson.reset_column_information

    Lesson.all.each { |l| l.update_attribute :chalkle_payment, 0 }
  end

  def down
  	remove_column :lessons, :chalkle_payment
  end
end
