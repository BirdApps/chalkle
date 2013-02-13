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
    helper LessonHelper
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
      row :status
      row :category
      row :lesson_type
      row :teacher
      if !lesson.published?
        row :teacher_bio do
          simple_format lesson.teacher_bio
        end
        row :do_during_class do
          simple_format lesson.do_during_class
        end
        row :learning_outcomes do
          simple_format lesson.learning_outcomes
        end
        row :availabilities do
          simple_format lesson.availabilities
        end
        row :prerequisites do
          simple_format lesson.prerequisites
        end
        row :additional_comments do
          simple_format lesson.additional_comments
        end
        row :created_at
        row :updated_at 
      end
      # row :teacher_gst_number do
      #   if lesson.teacher && lesson.teacher.gst?
      #     lesson.teacher.gst
      #   else
      #     "Not GST registered"
      #   end
      # end

      row "Price" do
        number_to_currency lesson.cost
      end
      row :donation
      row :teacher_cost do
        number_to_currency lesson.teacher_cost
      end
      row :venue_cost do
        number_to_currency lesson.venue_cost
      end
      row :duration do
        "#{lesson.duration / 60} minutes" if lesson.duration?
      end
      row :max_attendee
      row :min_attendee      

      #only view these for published classes
      if lesson.published?
        if current_admin_user.role=="super"
          row :teacher_payment do
            number_to_currency lesson.teacher_payment
          end
          row :income do
            number_to_currency lesson.income
          end
          row :uncollected_revenue do
            number_to_currency lesson.uncollected_revenue
          end
          row :attendance
          row :bookings_to_collect do
          "There are #{lesson.bookings.confirmed.visible.count - lesson.bookings.confirmed.visible.paid.count} more bookings to collect."
          end
        end
        row :rsvp_list do
          render partial: "/admin/lessons/rsvp_list", locals: { lesson: lesson, group_url: lesson.groups.collect{|g| g.url_name}, bookings: lesson.bookings.visible.interested.order("status desc"), role: current_admin_user.role }
        end
        row :start_at
        row :meetup_id do
          link_to lesson.meetup_id, lesson.meetup_data["event_url"] if lesson.meetup_data.present?
        end
        row :description do
          simple_format lesson.description
        end
        if current_admin_user.role=="super"
          row :meetup_data
        end
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

  action_item(only: :show, if: proc{ can?(:lesson_email, resource) && lesson.visible && (lesson.bookings.visible.confirmed.count > 0)}) do
    link_to 'Preclass emails', lesson_email_admin_lesson_path(resource)
  end

  action_item(only: :show, if: proc{ can?(:payment_summary_email,resource) && lesson.visible && (lesson.bookings.visible.confirmed.count > 0) && !lesson.class_not_done}) do
    link_to 'Payment email', payment_summary_email_admin_lesson_path(resource)
  end

  action_item(only: :show, if: proc{ can?(:meetup_template,resource) && lesson.visible && !lesson.published? }) do
    link_to 'Meetup Template', meetup_template_admin_lesson_path(resource)
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
    render partial: "/admin/lessons/lesson_email_template", locals: { bookings: lesson.bookings.visible.confirmed,
      teachers: lesson.teacher.present? ? lesson.teacher.name : nil,
      title: lesson.name.present? ? lesson.name : "that is coming up", price: lesson.cost.present? ? lesson.cost : 0,
      reference: lesson.meetup_id.present? ? lesson.meetup_id : "Your Name" }
  end

  member_action :payment_summary_email do
    lesson = Lesson.find(params[:id])
    render partial: "/admin/lessons/payment_summary_email", locals: { lesson: lesson }
  end

  member_action :meetup_template do
    lesson = Lesson.find(params[:id])
    render partial: "/admin/lessons/meetup_template", locals: { lesson: lesson }
  end

  form do |f|
    f.inputs :details do
      f.input :name
      f.input :category
      f.input :lesson_type, :as => :select, :collection => ["Beginner", "Intermediate", "Advanced"]
      f.input :teacher, :as => :select, :collection => Chalkler.accessible_by(current_ability).order("LOWER(name) ASC")
      if !lesson.published?
        f.input :teacher_bio
        f.input :do_during_class, :label => "What we will do during this class"
        f.input :learning_outcomes, :label => "What we will learn from this class"
        f.input :availabilities
        f.input :prerequisites
        f.input :additional_comments
      end
      f.input :max_attendee
      f.input :min_attendee
      f.input :donation
      f.input :cost, :label => "Price"
      f.input :teacher_cost
      f.input :venue_cost
      f.input :duration
      if lesson.published?
        f.input :teacher_payment, :label => "Teacher Payment (leave blank if not paid)"
        f.input :start_at
        f.input :description
      end
      f.input :status, :as => :select, :collection =>  ["Published","On-hold","Unreviewed"]
    end
    f.actions
  end
end
