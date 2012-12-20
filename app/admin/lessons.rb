ActiveAdmin.register Lesson do
  config.sort_order = "created_at_desc"

  filter :groups_name, :as => :select, :label => "Group",
    :collection => proc{ current_admin_user.groups.collect{ |g| [g.name, g.name] }}
  filter :name, as: :select, collection: Lesson.order("name ASC").all
  filter :category
  filter :teacher, as: :select, collection: Chalkler.order("name ASC").all
  filter :cost
  filter :start_at

  controller do
    def scoped_collection
      Lesson.visible
    end
  end

  index do
    column :id
    column :name
    column :groups do |lesson|
      lesson.groups.collect{|g| g.name}.join(", ")
    end
    column :category
    column :teacher
    column :cost
    column "Unpaid", :unpaid_count, sortable: false
    column :start_at
    column :created_at
    default_actions
  end

  show title: :name do |lesson|
    attributes_table do
      row :category
      row :teacher
      row :meetup_id do
        link_to lesson.meetup_id, lesson.meetup_data["event_url"]
      end
      row :cost
      row :teacher_cost
      row :venue_cost
      row :start_at
      row :duration
      row :visible
      row :bookings do
        "There are #{lesson.bookings.confirmed.count} confirmed bookings, #{lesson.bookings.paid.count} bookings have paid"
      end
      row :rsvp_list do
        render partial: '/shared/rsvp_list', locals: {bookings: lesson.bookings.interested}
      end
      row :description do
        simple_format lesson.description
      end
      row :meetup_data
    end
    active_admin_comments
  end

  action_item only: :show, if: proc{lesson.visible} do |lesson|
    link_to 'Delete', toggle_visible_admin_lesson_path(params[:id])
  end

  action_item only: :show, if: proc{!lesson.visible} do |lesson|
    link_to 'Restore record', toggle_visible_admin_lesson_path(params[:id])
  end

  member_action :toggle_visible do
    lesson = Lesson.find(params[:id])
    lesson.visible = !lesson.visible
    lesson.save
    redirect_to action: 'show'
  end

  form do |f|
    f.inputs :details do
      f.input :name
      f.input :category
      f.input :teacher, as: :select, collection: Chalkler.order("name ASC").all
      f.input :cost
      f.input :teacher_cost
      f.input :venue_cost
      f.input :start_at
      f.input :visible, :as => :hidden, :value => "true"
      f.input :duration
      f.input :description
    end
    f.buttons
  end
end
