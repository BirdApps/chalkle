ActiveAdmin.register Lesson  do
  config.sort_order = "start_at_desc"

  controller do
    load_resource :except => :index
    authorize_resource
  end

  filter :groups_name, :as => :select, :label => "Group",
    :collection => proc{ current_admin_user.groups.collect{ |g| [g.name, g.name] }}
  filter :meetup_id
  filter :name
  filter :category
  filter :teacher, as: :select, :collection => proc{ Chalkler.accessible_by(current_ability).order("LOWER(name) ASC") }
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
    column :attendance
    column :groups do |lesson|
      lesson.groups.collect{|g| g.name}.join(", ")
    end
    column :category
    column :teacher
    column :cost do |lesson|
      number_to_currency lesson.cost
    end
    if current_admin_user.role=="super"
      column "Unpaid Amount" do |lesson|
        number_to_currency lesson.uncollected_revenue, sortable: false
     end
    end
    column :start_at
    default_actions
  end

  show title: :name do |lesson|
    attributes_table do
     row :attendance
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
      if current_admin_user.role=="super"
        row :bookings_to_collect do
          "There are #{lesson.bookings.confirmed.visible.count - lesson.bookings.confirmed.visible.paid.count} more bookings to collect."
        end
      end
      row :rsvp_list do
        render partial: "/admin/lessons/rsvp_list", locals: { bookings: lesson.bookings.visible.interested.order("status desc"), role: current_admin_user.role }
      end
      row :description do
        simple_format lesson.description
      end
      if current_admin_user.role=="super"
        row :meetup_data
      end
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

  action_item(only: :show, if: proc{ can?(:lesson_email, resource) && lesson.visible && lesson.bookings.visible.interested.count > 0}) do
    link_to 'Show emails', lesson_email_admin_lesson_path(resource)
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

  member_action :lesson_email do
    lesson = Lesson.find(params[:id])
    render partial: "/admin/lessons/lesson_email_template", locals: { bookings: lesson.bookings.visible.interested,
      teachers: lesson.teacher.present? ? lesson.teacher.name : nil,
      title: lesson.name.present? ? lesson.name : "that is coming up", price: lesson.cost.present? ? lesson.cost : 0,
      reference: lesson.meetup_id.present? ? lesson.meetup_id : "Your Name" }
  end

  form do |f|
    f.inputs :details do
      f.input :name
      f.input :category
      f.input :teacher, :as => :select, :collection => Chalkler.accessible_by(current_ability).order("LOWER(name) ASC")
      f.input :cost
      f.input :teacher_cost
      f.input :venue_cost
      f.input :start_at
      f.input :duration
      f.input :description
    end
    f.actions
  end
end
