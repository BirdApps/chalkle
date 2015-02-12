class AddProviderIdToLessons < ActiveRecord::Migration
  def change
  	add_column :lessons, :provider_id, :integer
  end
end
