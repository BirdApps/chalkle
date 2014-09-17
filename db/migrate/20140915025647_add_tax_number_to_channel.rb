class AddTaxNumberToChannel < ActiveRecord::Migration
  def change
    add_column :channels, :tax_number, :string
  end
end
