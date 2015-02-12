class AddShortDescriptionToProviders < ActiveRecord::Migration
  def change
    add_column :providers, :short_description, :string
  end
end
