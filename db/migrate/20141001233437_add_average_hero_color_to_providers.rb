class AddAverageHeroColorToProviders < ActiveRecord::Migration
  def change
    add_column :providers, :average_hero_color, :string
  end
end
