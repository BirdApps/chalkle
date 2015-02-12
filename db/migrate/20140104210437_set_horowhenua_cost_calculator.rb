class SetHorowhenuaCostCalculator < ActiveRecord::Migration
  def up
    execute "UPDATE providers SET cost_model_id = 2 WHERE name = 'Horowhenua'"
  end

  def down
    execute "UPDATE providers SET cost_model_id NULL WHERE name = 'Horowhenua'"
  end
end
