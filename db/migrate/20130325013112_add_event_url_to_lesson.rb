class AddEventUrlToLesson < ActiveRecord::Migration
  def change
    add_column :lessons, :event_url, :string
  end
end
