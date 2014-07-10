class AddCancelledToLesson < ActiveRecord::Migration
  def change
    add_column :lessons, :cancelled, :boolean, default: false
  end
end
