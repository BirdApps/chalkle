class CreateCourseNotice < ActiveRecord::Migration
  def change
    create_table :course_notices do |t|
      t.integer   :chalkler_id
      t.integer   :course_id,   null: false
      t.text      :body,        null: false
      t.boolean   :visible,     null: false,  default: true
      t.string    :photo
      t.timestamps
    end
    add_foreign_key :course_notices, :chalklers
    add_foreign_key :course_notices, :courses
  end
end