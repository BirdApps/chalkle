ActiveAdmin.register Lesson  do
  csv do
    column :id
    column :name
    column("Price") { |lesson| number_to_currency lesson.cost }
    column("Class Date") { |lesson| lesson.start_at.strftime("%B %d, %Y") if lesson.start_at.present? }
    column("Class Time") { |lesson| lesson.start_at.strftime("%l:%M%p") if lesson.start_at.present? }
  end
  config.sort_order = "start_at_desc"

  controller do
    load_resource :except => :index
    authorize_resource
  end

  scope :published
  scope :unpublished

  filter :channels_name, :as => :select, :label => "Channel",
    :collection => proc{ current_admin_user.channels.collect{ |c| [c.name, c.name] }}
  filter :meetup_id
  filter :name
  filter :categories_name, :as => :select, :label => "Category",
    :collection => proc{ Category.all.collect{ |c| [c.name, c.name] }}
  filter :teacher, as: :select, :collection => proc{ Chalkler.accessible_by(current_ability).order("LOWER(name) ASC") }
  filter :cost
  filter :start_at

  controller do
    def scoped_collection
      end_of_association_chain.visible.accessible_by(current_ability)
    end
    helper LessonHelper
    helper BookingHelper

    def update
      params[:lesson][:duration] = (params[:lesson][:duration].to_d*60*60).to_i unless params[:lesson][:duration].blank?
      params[:lesson][:chalkle_percentage_override] = (params[:lesson][:chalkle_percentage_override].to_d/100).to_s unless params[:lesson][:chalkle_percentage_override].blank?
      params[:lesson][:channel_percentage_override] = (params[:lesson][:channel_percentage_override].to_d/100).to_s unless params[:lesson][:channel_percentage_override].blank?
      update!
    end

  end

  index do
    column :id
    column :name
    column :attendance, :sortable => false
    column :channels do |lesson|
      lesson.channels.collect{ |c| c.name}.join(", ")
    end
    column :categories do |lesson|
      lesson.categories.collect{ |c| c.name}.join(", ")
    end
    column :teacher
    column :cost do |lesson|
      number_to_currency lesson.cost
    end
    if current_admin_user.role=="super"
      column "Unpaid Amount" do |lesson|
        number_to_currency lesson.uncollected_turnover, sortable: false
     end
    end
    column :start_at
    default_actions
  end

  show title: :name do |lesson|
    attributes_table do
      row :status
      row :meetup_id do
        link_to lesson.meetup_id, lesson.meetup_data["event_url"] if lesson.meetup_data.present?
      end
      row :teacher
      row "Teacher's email" do |lesson|
        if lesson.teacher_id.present?
          if Chalkler.find(lesson.teacher_id).email?
            Chalkler.find(lesson.teacher_id).email
          else
            status_tag( "Please click on teacher above and enter their email", :error )
          end
        else
          status_tag("Please select a teacher and make sure there is an email contact", :error)
        end
      end
      row :categories do |lesson|
        lesson.categories.collect{ |c| c.name}.join(", ")
      end
      row :channels do |lesson|
        lesson.channels.collect{ |c| c.name}.join(", ")
      end
      row "Class Date" do |lesson|
        if lesson.start_at.present?
          lesson.start_at
        else
          status_tag("This class must have a date and time", :error)
        end
      end    
      row "Availability of the teacher" do
        lesson.availabilities
      end
      row "venue for this class" do
        if lesson.venue.present?
          lesson.venue_cost
        else
          status_tag("This class must have a venue", :error)
        end
      end
      row "What we are doing" do
        if lesson.do_during_class.present?
          simple_format lesson.do_during_class
        else
          status_tag("This class must have a what we will do during the class", :error)
        end
      end
      row "What you will learn" do
        simple_format lesson.learning_outcomes
      end
      row "type of class" do
        lesson.lesson_type
      end
      row "skill required" do
        lesson.lesson_skill
      end
      row "your chalkler will be" do
        simple_format lesson.teacher_bio
      end
      row "What to bring" do
        simple_format lesson.prerequisites
      end
      row "What type of audience is it appropriate for" do
        simple_format lesson.suggested_audience
      end
      row :additional_comments do
        simple_format lesson.additional_comments
      end
      row "Advertised price (incl GST)" do
        number_to_currency lesson.cost
      end
      row "Teacher fee per attendee (incl. GST if any)" do
        if lesson.teacher_cost.present?
          number_to_currency lesson.teacher_cost
        else
          status_tag("This class must have a teacher cost. Insert 0 if the teacher is not being paid", :error)
        end
      end
      row "Chalkle fee per attendee (incl. GST and rounding)" do
        number_to_currency lesson.chalkle_cost
      end
      row "Channel fee per attendee (incl. GST)" do
        number_to_currency lesson.channel_cost
      end
      row :venue_cost do
        if lesson.venue_cost.present?
          number_to_currency lesson.venue_cost
        else
          status_tag("This class must have a venue cost. Insert 0 if the venue is free", :error)
        end
      end
      row :material_cost do
        number_to_currency lesson.material_cost
      end
      row :duration do
        pluralize(lesson.duration / 60 / 60, "hour") if lesson.duration?
      end
      row :max_attendee
      row "Minimum Attendee" do
        if lesson.class_may_cancel
          status_tag("#{lesson.min_attendee} people required for this class. Lower this number if the class is still going ahead", :error)
        else
          lesson.min_attendee
        end
      end
      if lesson.published?
        row :attendance
        row "Channel income after paying GST" do
          number_to_currency lesson.income
        end
        if current_admin_user.role=="super"
          row :collected_turnover do
            number_to_currency lesson.collected_turnover
          end
          row :teacher_payment do
            number_to_currency lesson.teacher_payment
          end
          row :chalkle_payment do
            number_to_currency lesson.chalkle_payment
          end
          row :uncollected_turnover do
            number_to_currency lesson.uncollected_turnover
          end
          row :bookings_to_collect do
          "There are #{lesson.bookings.confirmed.visible.count - lesson.bookings.confirmed.visible.paid.count} more bookings to collect."
          end
        end
        row :rsvp_list do
          render partial: "/admin/lessons/rsvp_list", locals: { lesson: LessonDecorator.decorate(lesson), channel_url: (lesson.channels.present? ? lesson.channels.collect{|c| c.url_name} : Channel.find(1).url_name), bookings: lesson.bookings.visible.interested.order("status desc"), role: current_admin_user.role }
        end
        row :description do
          simple_format lesson.description
        end
        if current_admin_user.role=="super"
          row :meetup_data
        end
        row :created_at
        row :updated_at
      end

      row "Image for class listing" do |lesson|
        lesson.lesson_upload_image.present? ? image_tag(lesson.lesson_upload_image.url(:thumb).to_s) : "No image uploaded. Click on Edit Lesson to upload an image"
      end
      row "Chalkboard image" do |lesson|
        image_tag lesson.image.url if lesson.image
      end
      row :created_at
      row :published_at
      row :updated_at
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

  action_item(only: :show, if: proc{ can?(:payment_summary_email, resource) && lesson.visible && (lesson.bookings.visible.confirmed.count > 0) && !lesson.class_not_done}) do
    link_to 'Payment email', payment_summary_email_admin_lesson_path(resource)
  end

  action_item(only: :show, if: proc{ can?(:meetup_template, resource) && lesson.visible && !lesson.published? }) do
    link_to 'Meetup Template', meetup_template_admin_lesson_path(resource)
  end

  action_item(only: :show, if: proc{ can?(:copy_lesson, resource) }) do
    link_to 'Copy Lesson', copy_lesson_admin_lesson_path(resource)
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
      teachers: lesson.teacher.present? ? lesson.teacher.name.split[0].titleize : nil,
      title: lesson.name.present? ? lesson.name : "that is coming up", price: lesson.cost.present? ? lesson.cost : 0,
      reference: lesson.meetup_id.present? ? lesson.meetup_id : lesson.id, start_time: lesson.start_at, venue: lesson.venue }
  end

  member_action :payment_summary_email do
    lesson = Lesson.find(params[:id])
    render partial: "/admin/lessons/payment_summary_email", locals: { lesson: lesson }
  end

  member_action :meetup_template do
    lesson = Lesson.find(params[:id])
    render partial: "/admin/lessons/meetup_template", locals: { lesson: LessonDecorator.decorate(lesson) }
  end

  member_action :copy_lesson do
    lesson = Lesson.find(params[:id])
    if new_lesson = lesson.copy_lesson
      flash[:notice] = "Copy of #{lesson.name.titleize}"
      redirect_to admin_lesson_path(new_lesson)
    else
      flash[:warn] = 'This lesson cannot be copied'
      redirect_to :back
    end
  end

  form :partial => 'form'
end
