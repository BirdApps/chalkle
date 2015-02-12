class AddProviderDescriptionAndUrl < ActiveRecord::Migration
  def change
    add_column :providers, :description, :text
    add_column :providers, :website_url, :string
  end
end
