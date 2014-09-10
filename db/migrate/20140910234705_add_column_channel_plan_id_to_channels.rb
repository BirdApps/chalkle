class AddColumnChannelPlanIdToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :channel_plan_id, :integer
    Channel.reset_column_information
    community_plan = ChannelPlan.first
    Channel.all.each do |channel|
      channel.update_attribute 'channel_plan_id', community_plan.id
    end
  end
end
