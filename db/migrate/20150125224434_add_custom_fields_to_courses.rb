class AddCustomFieldsToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :custom_fields, :text
  end
end
