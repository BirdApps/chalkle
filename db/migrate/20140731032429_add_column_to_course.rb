class AddColumnToCourse < ActiveRecord::Migration
  def up
    add_column :courses, :url_name, :string
    Course.reset_column_information
    Course.all.each do |course|
      course.update_attribute(:url_name, course.name.parameterize )
    end
  end

  def down
    remove_column :courses, :url_name
  end
end
