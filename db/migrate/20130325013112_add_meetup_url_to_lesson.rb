class AddMeetupUrlToLesson < ActiveRecord::Migration
  def change
    add_column :lessons, :meetup_url, :string
  end
end
