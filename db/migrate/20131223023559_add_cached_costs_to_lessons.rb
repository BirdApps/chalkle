class AddCachedCostsToLessons < ActiveRecord::Migration
  def change
    add_column :lessons, :cached_provider_fee, :decimal, :precision => 8, :scale => 2
    add_column :lessons, :cached_chalkle_fee, :decimal, :precision => 8, :scale => 2
  end
end
