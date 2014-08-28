class Teaching
  include ActiveAttr::Model

  attr_accessor :course, :current_user, :title, :teacher_id, :teacher, :channel, :bio, :course_skill, :do_during_class, :learning_outcomes, :duration_hours, :duration_minutes, :free_course, :teacher_cost, :max_attendee, :min_attendee,
  :availabilities, :prerequisites, :additional_comments, :venue, :category_primary_id, :channels, :channel_id, :suggested_audience, :cost, :region_id, :start_at, :repeating, :repeat_frequency, :repeat_count, :course_class_type, :class_count, :street_number, :street_name, :city, :region, :country, :postal_code, :venue_cost, :override_channel_fee, :longitude, :latitude, :venue_address, :image, :agreeterms

  validates :title, :presence => { :message => "Title of class can not be blank" }
  validates :teacher_id, :presence => { :message => "You must be registered with chalkle first" }
  validates :do_during_class, :presence => { :message => "What we will do during the class can not be blank" }
  validates :learning_outcomes, :presence => { :message => "What we will learn from this class can not be blank" }
  validates :channel_id, :presence => { :message => "You must select a channel" }


  validates :repeat_count, :allow_blank => true, :numericality => { :greater_than_or_equal_to => 0, :message => "Repeat classes must be 1 or more"}
  validates :category_primary_id, :allow_blank => false, :numericality => { :greater_than => 0, :message => "You must select a primary category"}
  validates :channel_id, :allow_blank => false, :numericality => { :greater_than => 0, :message => "You must select a channel"}
  validates :teacher_cost, :allow_blank => true, :numericality => {:equal_to => 0, :message => "You can not be paid for a free class" }, :if => "self.free_course=='1'"
  validates :teacher_cost, :allow_blank => true, :numericality => {:greater_than_or_equal_to => 0, :message => "Only positive currencies are allowed" }
  validates :repeat_count, presence: true, if: :repeating?
  validates :repeat_frequency, presence: true, if: :repeating?

  def initialize(current_user)
  	@current_user = current_user
    if @current_user.channels.length > 0
      @channels = @current_user.channels
    else
      @channels = Channel.visible
    end
  end

  def course_args
    {
      name: @title,
      category: @category,
      course_skill: @course_skill,
      do_during_class: @do_during_class,
      learning_outcomes: @learning_outcomes,
      suggested_audience: @suggested_audience,
      prerequisites: @prerequisites,
      additional_comments: @additional_comments,
      street_number: @street_number,
      street_name: @street_name,
      city: @city,
      region: @region,
      postal_code: @postal_code,
      longitude: @longitude,
      latitude: @latitude,
      venue: @venue,
      channel: @channel,
      teacher: @teacher,
      min_attendee: @min_attendee.to_i,
      max_attendee: @max_attendee.to_i,
      cost: @cost,
      venue_cost: @venue_cost,
      teacher_cost: @teacher_cost,
      course_upload_image: @image,
      availabilities: @availabilities,
    }
  end

  def lesson_args(i)
    {
      start_at: @start_at[i],
      duration: (@duration_hours[i].to_i*60*60+@duration_minutes[i].to_i*60)
    }
  end

  def submit(params)
    course = repeat_course = new_course_ids = nil
    nth = 0
    if check_valid_input(params)
      if !@image
        @image = upload_image
      end
      if course?
        #create single course with lots of lessons on it
        course = Course.new course_args
        class_count.to_i.times do |i|
          lesson = Lesson.create lesson_args i
          course.lessons << lesson
        end
        course.save
        new_course_ids = course.id
      else
        if once_off?
          @repeat_count = 1
        else
          repeat_course = RepeatCourse.create()
        end

        #create as many repeating classes as needed
        @repeat_count.to_i.times do |i|
          #create a new course
          course = Course.new(course_args)
          lesson = Lesson.create lesson_args i
          course.lessons << lesson
          if repeating?
            #calculate the next class's start_at
            if weekly?
              class_starts = Time.parse(@start_at[i].to_s) + 7.days
              @start_at[i+1] = Time.new class_starts.year, class_starts.month, class_starts.day, class_starts.hour, class_starts.min
            elsif monthly?
              if i == 0
                nth = nth_wday_of(Time.parse start_at[i])
              end
              binding.pry
              @start_at[i+1] = nth_day_in(Time.parse(start_at[i].to_s), nth)
            end
            @duration_hours[i+1] = @duration_hours[i]
            @duration_minutes[i+1] = @duration_minutes[i]
            #add new course to RepeatCourse
            repeat_course.courses << course
          else
            #this will only happen is repeat_count == 1, but it is in the loop to avoid verbosity
            course.save
            new_course_ids = course.id
          end
        end
        if repeating?
          repeat_course.save
          new_course_ids = repeat_course.courses.map &:id
        end
      end
      binding.pry
      new_course_ids
    end
  end


  private
  def once_off?
    @repeating == "once-off" || @repeat_count.to_i < 2
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

  def upload_image
    #TODO: upload image
    @image
  end

  def check_valid_input(params)
    @course_class_type = params[:course_class_type]
    if params[:name].nil?
      @title = params[:title]
    else
      @title = params[:name]
    end
    @category_primary_id = params[:category_primary_id].to_i unless params[:category_primary_id].nil?
    @course_skill = params[:course_skill]
    @repeating = params[:repeating]
    @repeat_frequency = params[:repeat_frequency]
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
    @region = get_region params[:region]
    @region_id = @region.id
    @country = params[:country]
    @postal_code = params[:postal_code]
    @latitude = params[:latitude]
    @longitude = params[:longitude]
    @venue = params[:venue]
    @channel = get_channel params[:channel_id]
    @channel_id = @channel.id
    @teacher = get_teacher params[:teacher_id]
    @teacher_id = @teacher.id
    @min_attendee = params[:min_attendee]
    @max_attendee = params[:max_attendee]
    @venue_cost = params[:venue_cost]
    @teacher_cost = params[:teacher_cost]
    @image = params[:image]
    @availabilities = params[:availabilities]
    @cost = calculate_cost
    self.valid?
  end

  def get_teacher(teacher_id)
    if @channel.channel_teachers.count == 1
      teacher = @channel.channel_teachers[0]
    elsif teacher_id.nil?
      teacher = ChannelTeacher.create chalkler: @current_user.chalkler, channel: @channel, name: @current_user.chalkler.name
    else
      teacher = @channel.channel_teachers.find teacher_id
    end
  end

  def get_channel(channel_id)
    if channel_id.nil?
      #no channel
      if @current_user.channels.empty?
        #create a personal channel and grant user all permissions
        channel = Channel.create name: @current_user.name, regions: [ region ], channel_rate_override: 0, teacher_percentage: 1, email: @current_user.email, visible: true
        channel_admin = ChannelAdmin.create channel: channel, chalkler: @current_user.chalkler
        channel_teacher = ChannelTeacher.create channel: channel, chalkler: @current_user.chalkler, name: @current_user.chalkler.name
      else
        if @current_user.channels.count == 1
          channel = @current_user.channels[0]
        end
      end
    else
      channel = @current_user.channels.select{ |channel| channel.id == channel_id.to_i }[0]
    end
    channel
  end

  def get_region(region_name)
    region_name = region_name || @city
    region = Region.find_by_name(region_name)
    if(region.nil?)
      region = Region.create name: region_name, url_name: region_name.parameterize
    end
    region
  end

  def calculate_cost
    #TODO: calculate cost based on course
    #if override_channel_fee
  end
end
