class CreatePartnerInquiries < ActiveRecord::Migration
  def change
    create_table :partner_inquiries do |t|
      t.string :name
      t.string :organisation
      t.string :location
      t.string :contact_details
      t.string :organisation_activity
      t.boolean :core_product_is_teaching
      t.string :class_cost
      t.boolean :free_classes
      t.integer :class_count
      t.integer :teacher_count

      t.timestamps
    end
  end
end
