ActiveAdmin.register Payment do
  config.sort_order = "date_desc"

  filter :xero_contact_name
  filter :total
  filter :created_ad
  filter :updated_at

  controller do
    def scoped_collection
      Payment.visible
    end
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

  action_item only: :index do
    link_to 'Reconcile', reconcile_admin_payments_path
  end

  action_item only: :show, if: proc{ !payment.complete_record_downloaded } do |payment|
    link_to 'Download from Xero', download_from_xero_admin_payment_path(params[:id])
  end

  action_item(only: :show, if: proc { can?(:hide, resource) && payment.visible }) do
    link_to 'Delete Payment',
      hide_admin_payment_path(resource),
      :data => { :confirm => "Are you sure you wish to delete this Payment?" }
  end

  action_item(only: :show, if: proc{ can?(:unhide, resource) && !payment.visible }) do
    link_to 'Restore Payment', unhide_admin_payment_path(resource)
  end

  collection_action :reconcile do
    @payments = Payment.unreconciled.limit(20)
  end

  member_action :download_from_xero do
    payment = Payment.find(params[:id])
    payment.complete_record_download
    redirect_to :action => :show
  end

  member_action :hide do
    payment = Payment.find(params[:id])
    payment.visible = false
    if payment.save!
      flash[:notice] = "Payment #{payment.id} deleted!"
    else
      flash[:warn] = "Payment #{payment.id} could not be deleted!"
    end
    redirect_to :back
  end

  member_action :unhide do
    payment = Payment.find(params[:id])
    payment.visible = true
    if payment.save!
      flash[:notice] = "Payment #{payment.id} restored!"
    else
      flash[:warn] = "Payment #{payment.id} could not be restored!"
    end
    redirect_to :back
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

  form do |f|
    f.inputs :details do
      f.input :booking
      f.input :xero_contact_name
      f.input :xero_id, :label => "Unique Xero ID (required)", :required => "true"
      f.input :date
      f.input :total
      f.input :reconciled
      f.input :complete_record_downloaded, :as => :hidden, :value => "true"
    end

    f.buttons
  end
end
