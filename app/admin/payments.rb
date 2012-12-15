ActiveAdmin.register Payment do
  config.sort_order = "date_desc"

  scope :show_invisible_only
  scope :show_visible_only, :default => true

  # filter :groups_name, :as => :select, :label => "Group",
    # :collection => proc{ current_admin_user.groups.collect{ |g| [g.name, g.name] }}
  filter :xero_contact_name
  filter :total
  filter :created_ad
  filter :updated_at

  action_item only: :index do
    link_to 'Reconcile', reconcile_admin_payments_path
  end

  action_item only: :show, if: proc{!payment.complete_record_downloaded} do |payment|
    link_to 'Download from Xero', download_from_xero_admin_payment_path(params[:id])
  end

  action_item only: :show, if: proc{payment.visible} do |payment|
    link_to 'Make Invisible', make_invisible_admin_payment_path(params[:id])
  end

  index do
    column :id
    column :reference
    column :date
    column :xero_contact_name
    column :reconciled
    column :total
    default_actions
  end

  collection_action :reconcile do
    @payments = Payment.unreconciled.limit(20)
  end

  member_action :download_from_xero do
    payment = Payment.find(params[:id])
    payment.complete_record_download
    redirect_to action: 'show'
  end

  member_action :make_invisible do
    payment = Payment.find(params[:id])
    payment.visible = false
    payment.save
    redirect_to action: 'show'
  end

  member_action :do_reconcile, method: :post do
    payment = Payment.find(params[:id])
    booking = Booking.find(params[:booking_id])
    payment.booking = booking
    payment.reconciled = true
    booking.paid = true
    if payment.save! && booking.save!
      render text: 'success', layout: false, status: 200
    else
      render text: 'error', layout: false, status: 500
    end
  end

end
