class AddChannelRateOverrideToLessons < ActiveRecord::Migration
  def change
    add_column :lessons, :channel_rate_override, :decimal, :precision => 8, :scale => 4
  end
end
