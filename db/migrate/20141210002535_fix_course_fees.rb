class FixCourseFees < ActiveRecord::Migration
  def up
    remove_column :courses, :description
    remove_column :courses, :availabilities
    remove_column :courses, :cached_provider_fee
    remove_column :courses, :cached_chalkle_fee
  end

  def down
    add_column :courses, :description, :text
    add_column :courses, :availabilities, :text
    add_column :courses, :cached_provider_fee, :decimal
    add_column :courses, :cached_chalkle_fee, :decimal
  end
end
