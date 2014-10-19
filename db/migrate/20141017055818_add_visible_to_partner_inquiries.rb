class AddVisibleToPartnerInquiries < ActiveRecord::Migration
  def change
    add_column :partner_inquiries, :visible, :boolean, default: :true
  end
end
