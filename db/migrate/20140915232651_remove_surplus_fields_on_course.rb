class RemoveSurplusFieldsOnCourse < ActiveRecord::Migration
  def up
    remove_column :courses, :meetup_id
    remove_column :courses, :meetup_data
    remove_column :courses, :meetup_url
    remove_column :courses, :venue_cost
    remove_column :courses, :material_cost
    remove_column :courses, :channel_rate_override
    remove_column :courses, :fixed_overhead_cost
    remove_column :courses, :deprecated_channel_percentage_override
    remove_column :courses, :deprecated_chalkle_percentage_override
    remove_column :courses, :donation
  end

  def down
    ActiveRecord::IrreversibleMigration
  end
end
