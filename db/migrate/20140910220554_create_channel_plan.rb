class CreateChannelPlan < ActiveRecord::Migration
  def up
    create_table :channel_plans do |t|
      t.string :name
      t.integer :max_channel_admins
      t.integer :max_teachers
      t.integer :max_free_class_attendees 
      t.decimal :class_attendee_cost 
      t.decimal :course_attendee_cost 
      t.decimal :annual_cost
      t.decimal :processing_fee_percent

      t.timestamps
    end

    ChannelPlan.reset_column_information
    community_plan = ChannelPlan.create(name: 'Community', max_admin_logins: 1,max_free_class_attendees: 20, class_attendee_cost: 2, course_attendee_cost: 6, annual_cost: 0, processing_fee_percent: 0.04, max_teachers: 1 )
    ChannelPlan.create(name: 'Standard',max_admin_logins: 2,max_free_class_attendees: 0,class_attendee_cost: 4,course_attendee_cost: 10,annual_cost: 0,processing_fee_percent: 0.04, max_teachers: 10 )
    ChannelPlan.create( name: 'Enterprise',max_admin_logins: 2, max_teachers: 10, max_free_class_attendees: nil,class_attendee_cost: 4,course_attendee_cost: 10, annual_cost: 3000,processing_fee_percent: 0.04 )

    add_column :channels, :channel_plan_id, :integer
    add_column :channels, :plan_name, :string
    add_column :channels, :plan_max_channel_admins, :integer
    add_column :channels, :plan_max_free_class_attendees, :integer
    add_column :channels, :plan_class_attendee_cost, :decimal
    add_column :channels, :plan_course_attendee_cost, :decimal
    add_column :channels, :plan_annual_cost, :decimal
    add_column :channels, :plan_processing_fee_percent, :decimal

        Channel.reset_column_information

    Channel.all.each do |channel|
      channel.update_attribute 'channel_plan_id', community_plan.id
    end

  end

  def down
    drop_table :channel_plans
  end
end
