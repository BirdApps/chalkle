class AddTaxAndAccountToProviderTeacher < ActiveRecord::Migration
  def change
    add_column :provider_teachers, :tax_number, :string
    add_column :provider_teachers, :account, :string
  end
end
