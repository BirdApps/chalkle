class AddBalanceToTeachers < ActiveRecord::Migration
  def change
    add_column :provider_teachers, :balance, :decimal
  end
end
