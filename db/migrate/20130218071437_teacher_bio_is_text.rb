class TeacherBioIsText < ActiveRecord::Migration
  def up
  	change_column :lessons, :teacher_bio, :text, :default => nil
  end

  def down
  	change_column :lessons, :teacher_bio, :string, :default => nil
  end
end
