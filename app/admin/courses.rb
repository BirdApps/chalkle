require 'carrierwave'
require 'course_upload_image_uploader'

ActiveAdmin.register Course  do
  csv do
    column :id
    column :name
    column("Price") { |course| number_to_currency course.cost }
    column("Class Date") { |course| course.start_at.strftime("%B %d, %Y") if course.start_at.present? }
    column("Class Time") { |course| course.start_at.strftime("%l:%M%p") if course.start_at.present? }
  end
  #config.sort_order = "start_at_desc"

  controller do
    load_resource :except => :index
    authorize_resource
  end

  scope :published, default: true
  scope :unpublished
  scope "Trash", :hidden

  filter :channel_name, :as => :select, :label => "Channel",
    :collection => proc{ current_admin_user.administerable_channels.collect{ |c| [c.name, c.name] }}
  filter :meetup_id
  filter :name
  filter :category_name, :as => :select, :label => "Category",
    :collection => proc{ Category.all.collect{ |c| [c.name, c.name] }}
  filter :teacher, as: :select, :collection => proc{ Chalkler.accessible_by(current_ability).order("LOWER(name) ASC") }
  filter :cost
  filter :start_at

  controller do
    def scoped_collection
      end_of_association_chain.accessible_by(current_ability)
    end
    helper CourseHelper
    helper BookingHelper

    def update
      params[:course][:duration] = (params[:course][:duration].to_d*60*60).to_i unless params[:course][:duration].blank?
      update!
    end

  end

  index do
    column :id
    column :name
    column :attendance, sortable: false
    column :region
    column :channel_name
    column :category_name, sortable: false
    column :teacher
    column :cost do |course|
      number_to_currency course.cost
    end
    if current_admin_user.role=="super"
      column "Unpaid Amount" do |course|
        number_to_currency course.uncollected_turnover, sortable: false
     end
    end
    #column :start_at
    column(:start_at) {|course| course.lessons.empty? ? nil : course.start_at.strftime("%B %d, %Y %H:%M") }
      

    default_actions
  end

  show title: :name do |course|
    attributes_table do
      row :status
      row :meetup_id do
        link_to course.meetup_id, course.meetup_data["event_url"] if course.meetup_data.present?
      end
      row :teacher
      row "Teacher's email" do |course|
        if course.teacher_id.present?
          if Chalkler.find(course.teacher_id).email?
            Chalkler.find(course.teacher_id).email
          else
            status_tag( "Please click on teacher above and enter their email", :error )
          end
        else
          status_tag("Please select a teacher and make sure there is an email contact", :error)
        end
      end
      row :region do |course|
        if course.region
          course.region.name
        else
          status_tag("This class must have a region", :error)
        end
      end
      row :category_name
      row :channel_name
      row "Class Date" do |course|
        if course.start_at.present?
          course.start_at
        else
          status_tag("This class must have a date and time", :error)
        end
      end    
      row "Availability of the teacher" do
        course.availabilities
      end
      row "venue for this class" do
        if course.venue?
          course.venue
        else
          status_tag("This class must have a venue", :error)
        end
      end
      row "What we are doing" do
        if course.do_during_class.present?
          simple_format course.do_during_class
        else
          status_tag("This class must have a what we will do during the class", :error)
        end
      end
      row "What you will learn" do
        simple_format course.learning_outcomes
      end
      row "type of class" do
        course.course_type
      end
      row "skill required" do
        course.course_skill
      end
      row "your chalkler will be" do
        simple_format course.teacher_bio
      end
      row "What to bring" do
        simple_format course.prerequisites
      end
      row "What type of audience is it appropriate for" do
        simple_format course.suggested_audience
      end
      row :additional_comments do
        simple_format course.additional_comments
      end
      row "Advertised price (incl GST)" do
        number_to_currency course.cost
      end
      row "Teacher fee per attendee (incl. GST if any)" do
        if course.teacher_cost.present?
          number_to_currency course.teacher_cost
        else
          status_tag("This class must have a teacher cost. Insert 0 if the teacher is not being paid", :error)
        end
      end
      row "Chalkle fee per attendee (incl. GST and rounding)" do
        number_to_currency course.chalkle_fee
      end
      row "Channel fee per attendee (incl. GST)" do
        number_to_currency course.channel_fee
      end
      row :venue_cost do
        if course.venue_cost.present?
          number_to_currency course.venue_cost
        else
          status_tag("This class must have a venue cost. Insert 0 if the venue is free", :error)
        end
      end
      row :material_cost do
        number_to_currency course.material_cost
      end
      row :duration do
        pluralize(course.duration / 60 / 60, "hour") if course.duration
      end
      row :max_attendee
      row "Minimum Attendee" do
        if course.class_may_cancel
          status_tag("#{course.min_attendee} people required for this class. Lower this number if the class is still going ahead", :error)
        else
          course.min_attendee
        end
      end
      if course.published?
        row :attendance
        row "Channel income after paying GST" do
          number_to_currency course.income
        end
        if current_admin_user.role=="super"
          row :collected_turnover do
            number_to_currency course.collected_turnover
          end
          row :teacher_payment do
            number_to_currency course.teacher_payment
          end
          row :chalkle_payment do
            number_to_currency course.chalkle_payment
          end
          row :uncollected_turnover do
            number_to_currency course.uncollected_turnover
          end
          row :bookings_to_collect do
          "There are #{course.bookings.confirmed.visible.count - course.bookings.confirmed.visible.paid.count} more bookings to collect."
          end
        end
        row :rsvp_list do
          render partial: "/admin/courses/rsvp_list", locals: { course: CourseDecorator.decorate(course), channel_url: (course.channel ? course.channel.url_name : Channel.find(1).url_name), bookings: course.bookings.visible.interested.order("status desc"), role: current_admin_user.role }
        end
        row :description do
          simple_format course.description
        end
        if current_admin_user.role=="super"
          row :meetup_data
        end
        row :created_at
        row :updated_at
      end

      row "Image for class listing" do |course|
        course.course_upload_image.present? ? image_tag(course.course_upload_image.url(:mini).to_s) : "No image uploaded. Click on Edit Course to upload an image"
      end
      row :created_at
      row :published_at
      row :updated_at
    end

    active_admin_comments
  end

  action_item(only: :show, if: proc { can?(:hide, resource) && course.visible }) do
    link_to 'Trash Course',
      hide_admin_course_path(resource),
      :data => { :confirm => "Are you sure you wish to trash this Course?" }
  end

  action_item(only: :show, if: proc{ can?(:unhide, resource) && !course.visible}) do
    link_to 'Restore record', unhide_admin_course_path(resource)
  end

  action_item(only: :show, if: proc{ can?(:course_email, resource) && course.visible && (course.bookings.visible.confirmed.count > 0)}) do
    link_to 'Preclass emails', course_email_admin_course_path(resource)
  end

  action_item(only: :show, if: proc{ can?(:payment_summary_email, resource) && course.visible && (course.bookings.visible.confirmed.count > 0) && !course.class_not_done}) do
    link_to 'Payment email', payment_summary_email_admin_course_path(resource)
  end

  action_item(only: :show, if: proc{ can?(:copy_course, resource) }) do
    link_to 'Copy Course', copy_course_admin_course_path(resource)
  end

  member_action :hide do
    course = Course.find(params[:id])
    course.visible = false
    if course.save!
      flash[:notice] = "Course #{course.id} trashed!"
    else
      flash[:warn] = "Course #{course.id} could not be trashed!"
    end
    redirect_to :action => :index
  end

  member_action :unhide do
    course = Course.find(params[:id])
    course.visible = true
    if course.save!
      flash[:notice] = "Course #{course.id} restored!"
    else
      flash[:warn] = "Course #{course.id} could not be restored!"
    end
    redirect_to :back
  end

  member_action :course_email do
    course = Course.find(params[:id])
    render partial: "/admin/courses/course_email_template", locals: { channel_id: course.channel_id, course_id: course.id, bookings: course.bookings.visible.confirmed,
      teachers: course.teacher.present? ? course.teacher.name.split[0].titleize : nil,
      title: course.name.present? ? course.name : "that is coming up", price: course.cost.present? ? course.cost : 0,
      reference: course.meetup_id.present? ? course.meetup_id : course.id, start_time: course.start_at, venue: course.venue }
  end

  member_action :payment_summary_email do
    course = Course.find(params[:id])
    render partial: "/admin/courses/payment_summary_email", locals: { course: course }
  end

  member_action :copy_course do
    course = Course.find(params[:id])
    if new_course = course.copy_course
      flash[:notice] = "Copy of #{course.name.titleize}"
      redirect_to admin_course_path(new_course)
    else
      flash[:warn] = 'This course cannot be copied'
      redirect_to :back
    end
  end

  form :partial => 'form'
end
