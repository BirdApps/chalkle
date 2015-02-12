class AddTaxNumberToProvider < ActiveRecord::Migration
  def change
    add_column :providers, :tax_number, :string
  end
end
