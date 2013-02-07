class AddDonationToLesson < ActiveRecord::Migration
  def up
    add_column :lessons, :donation, :boolean, :default => false

    Lesson.reset_column_information

    Lesson.all.each { |l| l.update_attribute :donation, false }
  end

  def down
    remove_column :lessons, :donation
  end
end
