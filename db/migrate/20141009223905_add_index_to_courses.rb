class AddIndexToCourses < ActiveRecord::Migration
  def change
    add_index :courses, :start_at
    add_index :courses, :status
    add_index :courses, :region_id
    add_index :courses, :url_name
    add_index :courses, :url_name
  end
end
