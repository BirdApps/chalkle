class SetHorowhenuaCostCalculator < ActiveRecord::Migration
  def up
    execute "UPDATE channels SET cost_model_id = 2 WHERE name = 'Horowhenua'"
  end

  def down
    execute "UPDATE channels SET cost_model_id NULL WHERE name = 'Horowhenua'"
  end
end
