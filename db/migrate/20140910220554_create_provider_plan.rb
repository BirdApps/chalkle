class CreateProviderPlan < ActiveRecord::Migration
  def up
    create_table :provider_plans do |t|
      t.string :name
      t.integer :max_provider_admins
      t.integer :max_teachers
      t.integer :max_free_class_attendees 
      t.decimal :class_attendee_cost 
      t.decimal :course_attendee_cost 
      t.decimal :annual_cost
      t.decimal :processing_fee_percent

      t.timestamps
    end

    ProviderPlan.reset_column_information
    community_plan = ProviderPlan.create(name: 'Community', max_provider_admins: 1,max_free_class_attendees: 20, class_attendee_cost: 2, course_attendee_cost: 6, annual_cost: 0, processing_fee_percent: 0.04, max_teachers: 1 )
    ProviderPlan.create(name: 'Standard',max_provider_admins: 2,max_free_class_attendees: 0,class_attendee_cost: 4,course_attendee_cost: 10,annual_cost: 0,processing_fee_percent: 0.04, max_teachers: 10 )
    ProviderPlan.create( name: 'Enterprise',max_provider_admins: 2, max_teachers: 10, max_free_class_attendees: nil,class_attendee_cost: 4,course_attendee_cost: 10, annual_cost: 3000,processing_fee_percent: 0.04 )

    add_column :providers, :provider_plan_id, :integer
    add_column :providers, :plan_name, :string
    add_column :providers, :plan_max_provider_admins, :integer
    add_column :providers, :plan_max_free_class_attendees, :integer
    add_column :providers, :plan_class_attendee_cost, :decimal
    add_column :providers, :plan_course_attendee_cost, :decimal
    add_column :providers, :plan_annual_cost, :decimal
    add_column :providers, :plan_processing_fee_percent, :decimal

        Provider.reset_column_information

    Provider.all.each do |provider|
      provider.update_attribute 'provider_plan_id', community_plan.id
    end

  end

  def down
    drop_table :provider_plans
  end
end
