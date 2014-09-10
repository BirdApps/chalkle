class CreateChannelPlan < ActiveRecord::Migration
  def up
    create_table :channel_plans do |t|
      t.string :name
      t.integer :max_admin_logins 
      t.integer :max_free_class_attendees 
      t.decimal :class_attendee_cost 
      t.decimal :course_attendee_cost 
      t.decimal :annual_cost
      t.decimal :processing_fee_percent
      
      t.timestamps
    end

    ChannelPlan.reset_column_information
    ChannelPlan.create(name: 'Community', max_admin_logins: 2,max_free_class_attendees: 20, class_attendee_cost: 2, course_attendee_cost: 6, annual_cost: 0, processing_fee_percent: 0.4 )
    ChannelPlan.create(name: 'Standard',max_admin_logins: 2,max_free_class_attendees: 0,class_attendee_cost: 4,course_attendee_cost: 10,annual_cost: 0,processing_fee_percent: 0.4 )
    ChannelPlan.create( name: 'Enterprise',max_admin_logins: 4,max_free_class_attendees: 0,class_attendee_cost: 4,course_attendee_cost: 10, annual_cost: 3000,processing_fee_percent: 0.4 )
  end

  def down
    drop_table :channel_plans
  end
end
