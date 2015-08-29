class CreateChalklerCourseNotifications < ActiveRecord::Migration
  def change
    create_table :chalkler_course_notifications do |t|
      t.integer   :chalkler_id, null: false
      t.integer   :course_id,   null: false
      t.datetime  :sent_at
      t.timestamps
    end
  end
end
