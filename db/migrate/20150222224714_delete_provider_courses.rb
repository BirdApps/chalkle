class DeleteProviderCourses < ActiveRecord::Migration
  def up
    drop_table :provider_courses
  end

  def down
    ActiveRecord::IrreversibleMigration
  end
end
