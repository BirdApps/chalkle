class AddStateToEventLogs < ActiveRecord::Migration
  def change
    add_column :event_logs, :state, :string, default: 'new'
    add_column :event_logs, :error, :string
  end
end
