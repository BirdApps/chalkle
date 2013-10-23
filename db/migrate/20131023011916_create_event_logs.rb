class CreateEventLogs < ActiveRecord::Migration
  def change
    create_table :event_logs do |t|
      t.string :name
      t.datetime :started_at, :completed_at
    end
  end
end
