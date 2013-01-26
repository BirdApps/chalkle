ActiveAdmin.register Booking do
  config.sort_order = "created_at_desc"

  scope :paid
  scope :confirmed
  scope :billable
  scope :waitlist

  filter :lesson_groups_name, :as => :select, :label => "Group",
    :collection => proc{ current_admin_user.groups.collect{|g| [g.name, g.name] }}
  filter :meetup_id
  filter :lesson, as: :select, collection: proc{ Lesson.accessible_by(current_ability).order("LOWER(name) ASC").visible }
  filter :chalkler, as: :select, collection: Chalkler.order("name ASC").all
  filter :cost
  filter :paid
  filter :guests
  filter :created_at

  controller do
    load_resource :except => :index
    authorize_resource

    def scoped_collection
      end_of_association_chain.visible.interested.accessible_by(current_ability)
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
      row :lesson
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
    end
    active_admin_comments
  end

  action_item(only: :show, if: proc { can?(:hide, resource) && booking.visible }) do
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

  form do |f|
    f.inputs :details do
      f.input :lesson, as: :select, :collection => Lesson.accessible_by(current_ability).visible.order("LOWER(name) ASC")
      f.input :chalkler, as: :select, collection: Chalkler.accessible_by(current_ability).order("LOWER(name) ASC")
      f.input :guests
      f.input :cost_override, label: "cost override (Leave empty for no override)"
      f.input :status, as: :select, collection: ["yes", "no", "waitlist", "no-show"]
      f.input :paid
    end
    f.buttons
  end
end
