class AddCancelledReasonToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :cancelled_reason, :string
  end
end
