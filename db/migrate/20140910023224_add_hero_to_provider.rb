class AddHeroToProvider < ActiveRecord::Migration
  def change
    add_column :providers, :hero, :string
  end
end
