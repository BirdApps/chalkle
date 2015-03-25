class RemoveCourseSuggestion < ActiveRecord::Migration
  def up
    drop_table :provider_course_suggestions
    drop_table :course_suggestions
  end

  def down
    ActiveRecord::IrreversibleMigration
  end
end
