class CreateCourseNotice < ActiveRecord::Migration
  def change
    create_table :course_notices do |t|
      t.integer   :chalkler_id
      t.integer   :course_id,   null: false
      t.text      :body,        null: false
      t.timestamps
    end
  end
end