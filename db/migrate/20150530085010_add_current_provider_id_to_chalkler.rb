class AddCurrentProviderIdToChalkler < ActiveRecord::Migration
  def change
    add_column :chalklers, :current_provider_id, :integer
  end
end
