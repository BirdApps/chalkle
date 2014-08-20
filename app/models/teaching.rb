class Teaching
  include ActiveAttr::Model

  attr_accessor :course, :chalkler, :title, :teacher_id, :bio, :course_skill, :do_during_class, :learning_outcomes, :duration_hours, :duration_minutes, :free_course, :teacher_cost, :max_attendee, :min_attendee,
  :availabilities, :prerequisites, :additional_comments, :venue, :category_primary_id, :channels, :channel_id, :suggested_audience, :cost, :region_id, :start_at, :repeating, :repeat_frequency, :repeat_count, :course_class_type, :class_count, :street_number, :street_name, :city, :region, :country, :postal_code, :venue_cost, :waive_channel_fee, :longitude, :latitude

  validates :title, :presence => { :message => "Title of class can not be blank"}
  validates :teacher_id, :presence => { :message => "You must be registered with chalkle first"}
  validates :do_during_class, :presence => { :message => "What we will do during the class can not be blank"}
  validates :learning_outcomes, :presence => { :message => "What we will learn from this class can not be blank"}
  validates :repeat_count, :allow_blank => true, :numericality => { :greater_than_or_equal_to => 0, :message => "Repeat classes must be 1 or more"}
  validates :duration_hours, :allow_blank => false, :numericality => { :greater_than_or_equal_to => 0, :message => "Hours must be 0 or more"}
   validates :duration_minutes, :allow_blank => false, :numericality => { :greater_than_or_equal_to => 0, :message => "Minutes must be 0 or more"}
  validates :category_primary_id, :allow_blank => false, :numericality => { :greater_than => 0, :message => "You must select a primary category"}
  validates :channel_id, :allow_blank => false, :numericality => { :greater_than => 0, :message => "You must select a channel"}
  validates :teacher_cost, :allow_blank => true, :numericality => {:equal_to => 0, :message => "You can not be paid for a free class" }, :if => "self.free_course=='1'"
  validates :teacher_cost, :allow_blank => true, :numericality => {:greater_than_or_equal_to => 0, :message => "Only positive currencies are allowed" }
  validates :max_attendee, :allow_blank => true, :numericality => {:greater_than => 0, :message => "Number of people must be greater than 0" }
  validates :max_attendee, :allow_blank => true, :numericality => {:only_integer => true, :message => "Only integer number of people are allowed" }
  validates :min_attendee, :allow_blank => true, :numericality => {:greater_than_or_equal_to => 0, :message => "Number of people must be greater than or equal to 0" }
  validates :min_attendee, :allow_blank => true, :numericality => {:only_integer => true, :message => "Only integer number of people are allowed"  }
  validates :repeat_count, presence: true, if: :is_repeating
  validates :repeat_frequency, presence: true, if: :is_repeating

  def is_repeating
    @repeating == "repeating"
  end

  def repeats_monthly
    @repeat_frequency == "monthly" && is_repeating
  end

  def initialize(chalkler)
  	@chalkler = chalkler
    @teacher_id = @chalkler.id
    if @chalkler.channels.length > 0
      @channels = @chalkler.channels
    else
      @channels = Channel.visible
    end
  end

  def course_args
    {
      name: meetup_event_name(@category_primary_id,@title),
      teacher_id: @teacher_id,
      course_skill: @course_skill,
      teacher_bio: @bio,
      do_during_class: @do_during_class,
      learning_outcomes: @learning_outcomes,
      cost: @cost,
      teacher_cost: @teacher_cost,
      max_attendee: @max_attendee.to_i,
      min_attendee: @min_attendee.to_i,
      availabilities: @availabilities,
      prerequisites: @prerequisites,
      additional_comments: @additional_comments,
      venue: @venue,
      suggested_audience: @suggested_audience,
      region_id: @region_id
    }
  end

  def nth_day_in(month, nth)
    start_at = Time.parse @start_at
    current_nth = 0;
    months = start_at.month+month;
    add_years = months/12;
    months = months%12
    if months == 0
      months = 12 
      add_years = 0 if add_years == 1
    end
    start_at = Time.parse @start_at
    date_lapse = Date.new start_at.year+add_years, months, 1;
    until current_nth == nth do
      current_nth = current_nth + 1 if(date_lapse.wday == start_at.wday)
      date_lapse = date_lapse.next_day
    end
    date_lapse = date_lapse.prev_day
    Time.new date_lapse.year, date_lapse.month, date_lapse.day, start_at.hour, start_at.min
  end

  def nth_wday_of_start_at
    nth = 1
    start_at = Time.parse @start_at
    date_lapse = Date.new start_at.year, start_at.month, 1
    until (date_lapse.day == start_at.day) do
      nth = nth + 1 if (date_lapse.wday == start_at.wday)
      date_lapse = date_lapse.next_day
    end
    nth = 4 if nth > 4
    nth
  end

  def calculate_monthly_course_dates
    course_dates = [];
    nth = nth_wday_of_start_at
    @repeat_count.to_i.times do |multiplier|
      course_dates << nth_day_in(multiplier, nth)
    end
    course_dates
  end

  def submit(params)
    if check_valid_input(params)
      repeating = @repeating == 'repeating'
      starting = Time.parse(@start_at)
      if repeating
        @repeat_course = RepeatCourse.create()
      end
      course_dates = []
      @repeat_count ="1" if @repeat_count.to_i < 1
      @repeat_count.to_i.times do |multiplier|
        if @repeat_frequency == 'weekly' && repeating
          hour = starting.hour
          starting = Time.parse(@start_at) + 7.days*multiplier
          starting = Time.new(starting.year,starting.month,starting.day,hour,starting.min)
        elsif @repeat_frequency == 'monthly' && repeating
          if multiplier == 0
            course_dates = calculate_monthly_course_dates()
          else
            starting = course_dates[multiplier]
          end
        end
        lesson = Lesson.create({start_at: starting, duration: @duration_hours.to_i*60*60+@duration_minutes.to_i*60})
        @course = Course.new(course_args)
        @course.lessons = [lesson]
        @course.status = "Unreviewed"
        @course.category_id = @category_primary_id
        @course.channel = Channel.find(@channel_id) if @channel_id
        if @repeat_course
          @repeat_course.courses << @course
        else
          @course.save
        end  
      end
      if(@repeat_course)
        @repeat_course.save
        return @repeat_course.courses[0].id unless @repeat_course.nil? || @repeat_course.courses.nil? || @repeat_course.courses[0].nil?
      else
        return @course.id unless @course.nil?
      end
      false
    else
      return false
    end
  end


  def check_valid_input(params)
    if params[:name].nil?
      @title = params[:title]
    else
      @title = params[:name]
    end
    @course_skill = params[:course_skill]
    @do_during_class = params[:do_during_class]
    @learning_outcomes = params[:learning_outcomes]
    @duration_hours = params[:duration_hours]
    @duration_minutes = params[:duration_minutes]
    if @duration_hours != "" && @duration_minutes == ""
      @duration_minutes = 0
    end
    if @duration_minutes != "" && @duration_hours == ""
      @duration_hours = 0
    end
    @teacher_cost = params[:teacher_cost]
    @cost = params[:cost]
    @free_course = params[:free_course]
    @max_attendee = params[:max_attendee]
    @min_attendee = params[:min_attendee]
    @availabilities = params[:availabilities]
    @start_at = params[:start_at]
    @prerequisites = params[:prerequisites]
    @additional_comments = params[:additional_comments]
    @category_primary_id = params[:category_primary_id].to_i
    @repeating = params[:repeating]
    @repeat_frequency = params[:repeat_frequency]
    @repeat_day = params[:repeat_day]
    @repeat_month = params[:repeat_month]
    @repeat_count = params[:repeat_count]

    if @channels.length > 1
      @channel_id = params[:channel_id].to_i
    else
      @channel_id = @channels[0].id
    end
    @region_id = params[:region_id].to_i unless params[:region_id].blank?
    self.valid?
  end

  private

  def meetup_event_name(category_primary_id,title)
    return ( Category.find(category_primary_id, :select => "name").name + ": " + title ).downcase
  end

end
