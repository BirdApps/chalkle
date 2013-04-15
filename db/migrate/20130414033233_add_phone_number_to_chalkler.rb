class AddPhoneNumberToChalkler < ActiveRecord::Migration
  def change
  	add_column :chalklers, :phone_number, :string
  end
end
