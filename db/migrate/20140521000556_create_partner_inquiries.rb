class CreatePartnerInquiries < ActiveRecord::Migration
  def change
    create_table :partner_inquiries do |t|
      t.string :name
      t.string :organisation
      t.string :location
      t.string :contact_details
      t.text :comment

      t.timestamps
    end
  end
end
