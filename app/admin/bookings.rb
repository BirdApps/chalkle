ActiveAdmin.register Booking do
  scope :paid
  scope :confirmed
  scope :billable
  scope :waitlist
  config.sort_order = "created_at_desc"

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
      Booking.where("bookings.status = 'yes' OR bookings.status = 'waitlist'")
    end
  end

  index do
    column :id
    column :lesson
    column :chalkler
    column :groups do |booking|
      booking.lesson.groups.collect{|g| g.name}.join(", ")
      booking.set_paid
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

    end
    active_admin_comments

  end

  form do |f|
    f.inputs :details do
      f.input :lesson
      f.input :chalkler, as: :select, collection: Chalkler.order("name ASC").all
      f.input :guests
      f.input :status, as: :select, collection: ["yes", "no", "waitlist", "no-show"]
      f.input :paid
    end
    f.buttons
  end
end
