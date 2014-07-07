ActiveAdmin.register Booking do
  config.sort_order = "created_at_desc"

  scope :paid
  scope :confirmed
  scope :billable
  scope :waitlist
  scope :status_no

  filter :course_channel_name, :as => :select, :label => "Channel",
    :collection => proc{ current_admin_user.channels.collect{ |c| [c.name, c.name] }}
  filter :meetup_id
  filter :course, as: :select, collection: proc{ Course.accessible_by(current_ability).order("LOWER(name) ASC").visible }
  filter :chalkler, as: :select, collection: proc{ Chalkler.order("LOWER(name) ASC").all }
  filter :cost
  filter :paid
  filter :guests
  filter :created_at

  controller do
    load_resource :except => :index
    authorize_resource

    def scoped_collection
      end_of_association_chain.visible.accessible_by(current_ability)
    end
  end

  index do
    column :id
    column :course
    column :chalkler
    column :channels do |booking|
      booking.course.channel_name
    end
    column :status
    column :cost, :sortable => false do |booking|
      number_to_currency booking.cost
    end
    column :paid
    column :guests
    column :created_at
    default_actions
  end

  show do
    attributes_table do
      row :id
      row :course
      row :chalkler
      row :status
      row :guests
      row :cost do
        if booking.cost_override.nil?
          number_to_currency booking.cost
        else
          "#{number_to_currency booking.cost} (cost override)"
        end
      end
      row :paid
      row :answers do
        if booking.answers
          render partial: "/admin/bookings/answers", locals: { answers: booking.answers }
        end
      end
      row :meetup_data
      row :created_at
      row :updated_at
      row :reminder_last_sent_at
    end
    active_admin_comments
  end

  action_item(only: :show, if: proc { can?(:hide, resource) && booking.visible && (!booking.paid || booking.teacher?)}) do
    link_to 'Delete Booking',
      hide_admin_booking_path(resource),
      :data => { :confirm => "Are you sure you wish to delete this Booking?" }
  end

  action_item(only: :show, if: proc{ can?(:unhide, resource) && !booking.visible }) do
    link_to 'Restore Booking', unhide_admin_booking_path(resource)
  end

  member_action :hide do
    booking = Booking.find(params[:id])
    booking.visible = false
    if booking.save!
      flash[:notice] = "Booking #{booking.id} deleted!"
    else
      flash[:warn] = "Could not delete Booking!"
    end
    redirect_to :action => :index
  end

  member_action :unhide do
    booking = Booking.find(params[:id])
    booking.visible = true
    if booking.save!
      flash[:notice] = "Booking #{booking.id} restored!"
    else
      flash[:warn] = "Could not restore Booking!"
    end
    redirect_to :back
  end

  member_action :record_cash_payment do
    booking = Booking.find(params[:id])
    booking.paid = true
    booking.payment_method = 'free'
    desired_xero_id = "CASH-Class#{booking.course_id}-Chalkler#{booking.chalkler_id}"
    payment = Payment.find_or_initialize_by_xero_id desired_xero_id
    payment.reference = booking.course.meetup_id? ? "#{booking.course.meetup_id} #{booking.chalkler.name}" : "CourseID#{booking.course_id} #{booking.chalkler.name}"
    payment.xero_contact_id = booking.chalkler.name
    payment.xero_contact_name = booking.chalkler.name
    payment.date = Date.today()
    payment.booking_id = booking.id
    payment.reconciled = true
    payment.complete_record_downloaded = true
    payment.cash_payment = false
    payment.total = booking.cost
    payment.visible = true
    if booking.save! && payment.save!
      flash[:notice] = "Service desk payment of $#{(booking.cost).round(2)} was paid by #{booking.chalkler.name}"
    else
      flash[:warn] = "Service desk payment could not be recorded"
    end
    redirect_to :back
  end

  form do |f|
    f.inputs :details do
      f.input :course, as: :select, :collection => Course.accessible_by(current_ability).visible.order("LOWER(name) ASC").map{|l| ["#{l.name} - #{l.start_at? ? l.start_at.to_formatted_s(:short): "no date"}",l.id]}, :required => true
      f.input :chalkler, as: :select, collection: Chalkler.accessible_by(current_ability).order("LOWER(name) ASC"), :required => true
      f.input :guests
      f.input :payment_method, :as => :select, :collection => [['Bank', 'bank'],['Cash', 'cash'],['Meetup', 'meetup']], :hint => 'Leave blank on free classes'
      f.input :cost_override, label: "Cost override", :hint => "Leave blank for no override"
      f.input :status, as: :select, collection: ["yes", "no", "waitlist", "no-show"]
    end
    f.actions
  end
end
