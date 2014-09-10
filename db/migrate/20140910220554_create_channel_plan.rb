class CreateChannelPlan < ActiveRecord::Migration
  def up
    create_table :channel_plans do |t|
      t.string :name
      t.string :admin_logins 
      t.string :class_attendee_cost 
      t.string :course_attendee_cost 
      t.string :max_free_class_attendees 
      t.string :annual_cost
      
      t.timestamps
    end
  end

  def down
  end
end
