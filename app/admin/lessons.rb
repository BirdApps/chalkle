ActiveAdmin.register Lesson  do
  config.sort_order = "start_at_desc"

  filter :groups_name, :as => :select, :label => "Group",
    :collection => proc{ current_admin_user.groups.collect{ |g| [g.name, g.name] }}
  filter :meetup_id
  filter :name, as: :select, collection: Lesson.order("name ASC").all
  filter :category
  filter :teacher, as: :select, collection: Chalkler.order("name ASC").all
  filter :cost
  filter :start_at

  controller do
    def scoped_collection
      end_of_association_chain.visible.accessible_by(current_ability)
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
    column :cost do |lesson|
      number_to_currency lesson.cost
    end
    column "Unpaid", :unpaid_count, sortable: false
    column :start_at
    column :created_at
    default_actions
  end

  show title: :name do |lesson|
    attributes_table do
      row :category
      row :teacher
      row :teacher_gst_number do
        if lesson.teacher && lesson.teacher.gst?
          lesson.teacher.gst
        else
          "Not GST registered"
        end
      end
      row :meetup_id do
        link_to lesson.meetup_id, lesson.meetup_data["event_url"] if lesson.meetup_data.present?
      end
      row :cost do
        number_to_currency lesson.cost
      end
      row :teacher_cost do
        number_to_currency lesson.teacher_cost
      end
      row :venue_cost do
        number_to_currency lesson.venue_cost
      end
      row :start_at
      row :duration do
        "#{lesson.duration / 60} minutes" if lesson.duration?
      end
      row :bookings do
        "There are #{lesson.bookings.confirmed.count} confirmed bookings, #{lesson.bookings.paid.count} bookings have paid"
      end
      row :rsvp_list do
        render partial: "/admin/lessons/rsvp_list", locals: { bookings: lesson.bookings.visible.interested }
      end
      row :description do
        simple_format lesson.description
      end
      row :meetup_data
    end
    active_admin_comments
  end

  action_item(only: :show, if: proc { can?(:hide, resource) && lesson.visible }) do
    link_to 'Delete Lesson',
      hide_admin_lesson_path(resource),
      :data => { :confirm => "Are you sure you wish to delete this Lesson?" }
  end

  action_item(only: :show, if: proc{ can?(:unhide, resource) && !lesson.visible}) do
    link_to 'Restore record', unhide_admin_lesson_path(resource)
  end

  member_action :hide do
    lesson = Lesson.find(params[:id])
    lesson.visible = false
    if lesson.save!
      flash[:notice] = "Lesson #{lesson.id} deleted!"
    else
      flash[:warn] = "Lesson #{lesson.id} could not be deleted!"
    end
    redirect_to :action => :index
  end

  member_action :unhide do
    lesson = Lesson.find(params[:id])
    lesson.visible = true
    if lesson.save!
      flash[:notice] = "Lesson #{lesson.id} restored!"
    else
      flash[:warn] = "Lesson #{lesson.id} could not be restored!"
    end
    redirect_to :back
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
      f.input :duration
      f.input :description
    end
    f.buttons
  end
end
