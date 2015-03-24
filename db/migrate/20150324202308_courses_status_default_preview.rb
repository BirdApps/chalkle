class CoursesStatusDefaultPreview < ActiveRecord::Migration
  def up
    change_column :courses, :status, :string, :null => false, default: 'Preview'
  end

  def down
    change_column :courses, :status, :string, :null => false, default: 'Draft'
  end
end
