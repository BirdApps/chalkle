ActiveAdmin.register Booking do
  scope :paid
  scope :confirmed
  scope :billable
  scope :waitlist
  scope :show_invisible_only
  scope :show_visible_only, :default => true
  config.sort_order = "created_at_desc"

  filter :lesson_groups_name, :as => :select, :label => "Group",
    :collection => proc{ current_admin_user.groups.collect{|g| [g.name, g.name] }}
  filter :lesson
  filter :chalkler
  filter :cost
  filter :paid
  filter :guests
  filter :created_at

  action_item only: :show, if: proc{booking.visible} do |booking|
    link_to 'Make Invisible', change_visible_admin_booking_path(params[:id])
  end

  action_item only: :show, if: proc{!booking.visible} do |booking|
    link_to 'Make Visible', change_visible_admin_booking_path(params[:id])
  end

  controller do
    def scoped_collection
      Booking.where("bookings.status = 'yes' OR bookings.status = 'waitlist'")
    end
  end

  member_action :change_visible do
    booking = Booking.find(params[:id])
    booking.visible = !booking.visible
    booking.save
    redirect_to action: 'show'
  end

  index do
    column :id
    column :lesson
    column :chalkler
    column :groups do |booking|
      booking.lesson.groups.collect{|g| g.name}.join(", ")
    end
    column :status
    column :cost, :sortable => false
    column :paid
    column :guests
    column :created_at
    default_actions
  end

  show do
    attributes_table do
      row :id
      row :lesson
      row :chalkler
      row :status
      row :guests
      row :cost
      row :paid
      row :meetup_data
      row :created_at
      row :updated_at
      row :visible
    end
    active_admin_comments

  end

  form do |f|
    f.inputs :details do
      f.input :lesson
      f.input :chalkler
      f.input :guests
      f.input :status, as: :select, collection: ["yes", "no", "waiting"]
      f.input :paid
      f.input :visible, :as => :hidden, :value => "true"
    end

    f.buttons
  end
end
