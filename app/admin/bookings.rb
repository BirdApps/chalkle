ActiveAdmin.register Booking do
  config.sort_order = "created_at_desc"

  scope :paid
  scope :confirmed
  scope :billable
  scope :waitlist

  filter :lesson_groups_name, :as => :select, :label => "Group",
    :collection => proc{ current_admin_user.groups.collect{|g| [g.name, g.name] }}
  filter :lesson, as: :select, collection: Lesson.order("name ASC").all
  filter :chalkler, as: :select, collection: Chalkler.order("name ASC").all
  filter :cost
  filter :paid
  filter :guests
  filter :created_at

  controller do
    def scoped_collection
      Booking.visible.interested
    end
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
      row :additional_cost
      row :paid
      row :meetup_data
      row :created_at
      row :updated_at
      row :visible
    end
    active_admin_comments
  end

  action_item(only: :show, if: proc { can?(:set_visible, resource) && booking.visible }) do
    link_to 'Delete Booking',
      set_visible_admin_booking_path(resource),
      :data => { :confirm => "Are you sure you wish to delete this Booking?" }
  end

  action_item(only: :show, if: proc{ can?(:set_visible, resource) && !booking.visible }) do
    link_to 'Restore Booking', set_visible_admin_booking_path(resource)
  end

  member_action :set_visible do
    booking = Booking.find(params[:id])
    booking.visible = !booking.visible
    booking.save
    redirect_to :admin_bookings
  end

  form do |f|
    f.inputs :details do
      f.input :lesson
      f.input :chalkler, as: :select, collection: Chalkler.order("name ASC").all
      f.input :guests
      f.input :additional_cost
      f.input :status, as: :select, collection: ["yes", "no", "waitlist", "no-show"]
      f.input :paid
    end
    f.buttons
  end
end
