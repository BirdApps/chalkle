class AddChalklerToProviderAdmin < ActiveRecord::Migration
  def change
    add_column :provider_admins, :chalkler_id, :integer
    add_foreign_key :provider_admins, :chalklers
  end
end
