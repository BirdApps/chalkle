class DeprecateLessonPercentageOverrides < ActiveRecord::Migration
  def up
    rename_column :lessons, :provider_percentage_override, :deprecated_provider_percentage_override
    rename_column :lessons, :chalkle_percentage_override, :deprecated_chalkle_percentage_override
  end

  def down
    rename_column :lessons, :deprecated_provider_percentage_override, :provider_percentage_override
    rename_column :lessons, :deprecated_chalkle_percentage_override, :chalkle_percentage_override
  end
end
