class AddPhoneNumberToChalkler < ActiveRecord::Migration
  def up
  	add_column :chalklers, :phone_number, :string, :default => nil

  	Chalkler.reset_column_information

    Chalkler.all.each { |l| l.update_attribute :phone_number, nil }
  end

  def down
  	remove_column :chalklers, :phone_number
  end
end
