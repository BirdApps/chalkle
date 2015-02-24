require 'carrierwave'
require 'course_upload_image_uploader'

class Teaching
  include ActiveAttr::Model

  attr_accessor :course, :current_user, :title, :teacher_id, :bio, :do_during_class, :learning_outcomes, :duration_hours, :duration_minutes, :teacher_cost, :max_attendee, :min_attendee, :prerequisites, :additional_comments, :venue, :providers, :provider, :provider_id, :suggested_audience, :cost, :start_at, :repeating, :repeat_frequency, :repeat_count, :course_class_type, :class_count, :street_number, :street_name, :city, :country, :postal_code, :override_provider_fee, :longitude, :latitude, :venue_address, :course_upload_image, :agreeterms, :editing_id, :teacher_pay_type, :new_provider_tax_number, :note_to_attendees, :new_provider_bank_number, :cloning_id, :bookings, :custom_fields

  validates :title, :presence => { :message => "Class name can not be blank" }
  validates :do_during_class, :presence => { :message => "Class activities cannot be blank" }
  validates :learning_outcomes, :presence => { :message => "Learning outcomes cannot be blank" }
  validates :repeat_count, :allow_blank => true, :numericality => { :greater_than_or_equal_to => 0, :message => "Repeat classes must be 1 or more"}
  validates :teacher_cost, :allow_blank => true, :numericality => {:greater_than_or_equal_to => 0, :message => "Only positive currencies are allowed" }
  validates :repeat_count, presence: true, if: :repeating?
  validates :repeat_frequency, presence: true, if: :repeating?

  CUSTOM_FIELD_TYPES = [{key: 'string', value: 'Text - Single line'}, {key: 'text', value: 'Text - Multiple lines'}, { key: 'select', value: 'Options - Single selection'}, { key: 'check_boxes', value: 'Options - Multiple selections'}]

  def self.custom_field_name(type)
    CUSTOM_FIELD_TYPES.select{|s| s[:key] == type}.first[:value] if CUSTOM_FIELD_TYPES.select{|s| s[:key] == type}.present?
  end

  def initialize(current_user)
  	@current_user = current_user
    @providers = current_user.providers
    @start_at = [ Time.new.advance(weeks: 1) ]
    @duration_hours = [1]
    @duration_minutes = [0]
  end

  def course_to_teaching(args)
    #TODO: can only edit each course seperately at this point
    @repeating = 'once-off'
    
    @course_class_type = args.course_class_type
    if @course_class_type.nil?
      if args.course?
        @course_class_type = 'course'
      else
        @course_class_type = 'class'
      end
    end

    @class_count = args.lessons.count
    @title = args.name
    @do_during_class = args.do_during_class
    @learning_outcomes = args.learning_outcomes
    @suggested_audience = args.suggested_audience
    @prerequisites = args.prerequisites
    @additional_comments = args.additional_comments
    @street_number = args.street_number
    @street_name = args.street_name
    @city = args.city
    @postal_code = args.postal_code
    @longitude = args.longitude
    @latitude = args.latitude
    @venue = args.venue
    @provider_id = args.provider_id
    @teacher_id = args.teacher_id unless args.teacher.blank?
    @provider = args.provider
    @teacher = args.teacher
    @min_attendee = args.min_attendee
    @max_attendee = args.max_attendee
    @cost = args.cost
    @teacher_cost = args.teacher_cost
    @venue_address = args.venue_address
    @course_upload_image = args.course_upload_image
    @teacher_pay_type = args.teacher_pay_type
    @start_at = []
    @duration_hours = []
    @duration_minutes = []
    @note_to_attendees = args.note_to_attendees
    args.lessons.each do |lesson|
      @start_at << lesson.start_at
      @duration_hours << lesson.duration/60/60
      @duration_minutes << lesson.duration/60%60
    end
    @start_at << Time.current.advance(month: 1) if @start_at.empty?
    @editing_id = args.id
    @custom_fields = args.custom_fields
  end

  def course_args
    {
      name: @title,
      do_during_class: @do_during_class,
      learning_outcomes: @learning_outcomes,
      suggested_audience: @suggested_audience,
      prerequisites: @prerequisites,
      additional_comments: @additional_comments,
      street_number: @street_number,
      street_name: @street_name,
      city: @city,
      postal_code: @postal_code,
      longitude: @longitude,
      latitude: @latitude,
      venue: @venue,
      provider_id: @provider_id,
      teacher_id: @teacher_id,
      min_attendee: @min_attendee.to_i,
      max_attendee: @max_attendee.to_i,
      cost: @cost,
      teacher_cost: @teacher_cost,
      venue_address: @venue_address,
      course_upload_image: @course_upload_image,
      start_at: @start_at[0],
      teacher_pay_type: @teacher_pay_type,
      course_class_type: @course_class_type,
      note_to_attendees: @note_to_attendees,
      custom_fields: @custom_fields
    }
  end

  def lesson_args(i)
    {
      start_at: @start_at[i].to_datetime.to_s(:db),
      duration: (@duration_hours[i].to_i*60*60+@duration_minutes[i].to_i*60)
    }
  end

  def has_bookings?
    course = Course.find(@editing_id) if @editing_id
    course && course.bookings.present?
  end

  def update(course, params)
    course_to_teaching course
    if check_valid_input params
      if has_bookings?
        course_args.delete(:cost)
      end
      course.update_attributes course_args
      @class_count = 1 if !@class_count || @class_count == 0 || @class_count == "0"
      @class_count.to_i.times do |i|
        lesson = course.lessons[i]
        if lesson.present?
          lesson.update_attributes lesson_args i
          lesson.save
        else
          lesson = Lesson.create lesson_args i
          course.lessons << lesson
        end
      end
      course.save
    end
  end

  def submit(params)
    course = repeat_course = nil
    new_course_ids = []
    nth = 0
    if check_valid_input(params)
      if course?
        #create single course with lots of lessons on it
        course = Course.new course_args
        @class_count = 1 if !@class_count || @class_count == 0
        @class_count.to_i.times do |i|
          lesson = Lesson.create lesson_args i
          course.lessons << lesson
        end
        course.save
        new_course_ids << course.id
      else
        if once_off?
          @repeat_count = 1
        else
          repeat_course = RepeatCourse.create()
        end

        #create as many repeating classes as needed
        @repeat_count.to_i.times do |i|
          #create a new course
          course = Course.new course_args
          lesson = Lesson.create lesson_args i
          course.lessons << lesson
          if repeating?
            #calculate the next class's start_at
            if weekly?
              @start_at[i+1] = DateTime.parse(@start_at[i].to_s) + 7.days
            elsif monthly?
              if i == 0
                nth = nth_wday_of(DateTime.parse start_at[i].to_s)
              end
              @start_at[i+1] = nth_day_in(DateTime.parse(start_at[i].to_s), nth)
            end
            @duration_hours[i+1] = @duration_hours[i]
            @duration_minutes[i+1] = @duration_minutes[i]
            #add new course to RepeatCourse
            course.save
            repeat_course.courses << course
          else
            #this will only happen is repeat_count == 1, but it is in the loop to avoid verbosity
            course.save
            new_course_ids << course.id
          end
        end
        if repeating?
          repeat_course.save
          new_course_ids = repeat_course.courses.map &:id
        end
      end
      new_course_ids
    end
  end

  def editing?
    true if editing_id
  end


  def cloning?
    true if cloning_id
  end

  private
    def once_off?
      @repeating.blank? || @repeating == "once-off"
    end

    def repeating?
      !once_off?
    end

    def course?
      @course_class_type == "course"
    end

    def class?
      !course?
    end

    def monthly?
      @repeat_frequency == "monthly" && repeating?
    end

    def weekly?
      @repeat_frequency == "weekly" && repeating?
    end 


    #gets the nth start_at.wday in the next month
    def nth_day_in(start_at, nth)
      current_nth = 0;
      months = start_at.month+1
      add_years = months/12;
      months = months%12
      if months == 0
        months = 12 
        add_years = 0 if add_years == 1
      end
      date_lapse = Date.new start_at.year+add_years, months, 1;
      until current_nth == nth do
        current_nth = current_nth + 1 if(date_lapse.wday == start_at.wday)
        date_lapse = date_lapse.next_day
      end
      date_lapse = date_lapse.prev_day
      Time.new date_lapse.year, date_lapse.month, date_lapse.day, start_at.hour, start_at.min
    end

    #calculate start_at wday's nth position in the month
    def nth_wday_of(start_at)
      nth = 1
      date_lapse = Date.new start_at.year, start_at.month, 1
      until (date_lapse.day == start_at.day) do
        nth = nth + 1 if (date_lapse.wday == start_at.wday)
        date_lapse = date_lapse.next_day
      end
      nth = 4 if nth > 4
      nth
    end

    def check_valid_input(params)
      @course_class_type = params[:course_class_type]
      if params[:name].nil?
        @title = params[:title]
      else
        @title = params[:name]
      end
      @repeating = params[:repeating]
      @repeating = "once-off" if @repeating.blank?
      @repeat_frequency = params[:repeat_frequency]
      @repeat_frequency = "weekly" if @repeat_frequency.blank?
      @repeat_count = params[:repeat_count]
      @class_count = params[:class_count]
      @start_at = params[:start_at]
      @duration_hours = params[:duration_hours]
      @duration_minutes = params[:duration_minutes]
      @do_during_class = params[:do_during_class]
      @learning_outcomes = params[:learning_outcomes]
      @suggested_audience = params[:suggested_audience]
      @prerequisites = params[:prerequisites]
      @additional_comments = params[:additional_comments]
      @street_number = params[:street_number]
      @street_name = params[:street_name]
      @city = params[:city]
      @country = params[:country]
      @postal_code = params[:postal_code]
      @latitude = params[:latitude]
      @longitude = params[:longitude]
      @venue = params[:venue]
      @new_provider_bank_number = params[:new_provider_bank_number]
      @new_provider_tax_number = params[:new_provider_tax_number]
      @provider_id = get_provider_id params[:provider_id]
      @teacher_id = get_teacher_id params[:teacher_id]
      @min_attendee = params[:min_attendee]
      @max_attendee = params[:max_attendee]
      @teacher_cost = params[:teacher_cost]
      @venue_address = params[:venue_address]
      @course_upload_image = params[:course_upload_image]
      @course_upload_image = Course.find(params[:cloning_id]).course_upload_image if params[:cloning_id] && @course_upload_image.nil?
      @teacher_pay_type = params[:teacher_pay_type]
      @cost = params[:cost]
      @note_to_attendees = params[:note_to_attendees]
      if params[:custom_fields].present?
        @custom_fields = parse_custom_fields(params[:custom_fields])
      end
      self.valid?
    end

    def parse_custom_fields(fields)
      valid_fields = []
      fields = JSON.parse fields
      fields.each do |f|
        if f['type'] == 'radio_buttons' || f['type'] == 'select' || f['type'] == 'check_boxes'
          valid_fields << {
                            type: f['type'],
                            prompt: f['prompt'],
                            options: f['options'].split(',')
                          }
        elsif f['type'] == 'string' || f['type'] == 'text'
          valid_fields << {
                            type: f['type'],
                            prompt: f['prompt']
                          }
        end    
      end
      valid_fields
    end

    def get_teacher_id(teacher_id)
      if teacher_id.blank?
        if @provider.provider_teachers.present?
          teacher = @provider.provider_teachers.first
        else
          teacher = ProviderTeacher.create chalkler: @current_user.chalkler, provider: @provider, name: @current_user.name
        end
      else
        teacher = @provider.provider_teachers.find teacher_id
      end
      teacher.id
    end

    #If a provider was specified: use that, Else if user has a provider: use that, Else: create a new provider.
    def get_provider_id(provider_id)
      if provider_id.present?
        provider = Provider.find_by_id provider_id
        provider = nil unless @providers.include? provider || current_user.super?
      end
      if provider.blank?
        #no provider
        if @providers.empty?
          #create a personal provider and grant user all permissions
          provider = Provider.create({name: @current_user.name+" Classes", email: @current_user.email, account: @new_provider_bank_number, tax_number: @new_provider_tax_number, visible: true, provider_plan: ProviderPlan.default}, as: :admin)
          provider_admin = ProviderAdmin.create provider: provider, chalkler: @current_user.chalkler
          provider_teacher = ProviderTeacher.create provider: provider, chalkler: @current_user.chalkler, name: @current_user.name, account: @new_provider_bank_number, tax_number: @new_provider_tax_number
        else
          if @providers.count == 1
            provider = @providers[0]
          end
        end
      end
      @provider = provider
      provider.id
    end

end