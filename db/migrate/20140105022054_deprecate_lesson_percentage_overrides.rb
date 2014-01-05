class DeprecateLessonPercentageOverrides < ActiveRecord::Migration
  def up
    rename_column :lessons, :channel_percentage_override, :deprecated_channel_percentage_override
    rename_column :lessons, :chalkle_percentage_override, :deprecated_chalkle_percentage_override
  end

  def down
    rename_column :lessons, :deprecated_channel_percentage_override, :channel_percentage_override
    rename_column :lessons, :deprecated_chalkle_percentage_override, :chalkle_percentage_override
  end
end
