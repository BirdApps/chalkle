class Teaching
  include ActiveAttr::Model

  attr_accessor :lesson, :chalkler, :title, :teacher_id, :bio, :lesson_skill, :do_during_class, :learning_outcomes, :duration, :free_lesson, :teacher_cost, :max_attendee, :min_attendee, 
  :availabilities, :prerequisites, :additional_comments, :venue, :category_primary_id, :channels, :channel_id

  validates :title, :presence => { :message => "Title of class can not be blank"}
  validates :teacher_id, :presence => { :message => "You must be registered with chalkle first"}
  validates :do_during_class, :presence => { :message => "What we will do during the class can not be blank"}
  validates :learning_outcomes, :presence => { :message => "What we will learn from this class can not be blank"}
  validates :duration, :allow_blank => true, :numericality => { :greater_than_or_equal_to => 0, :message => "Only positive hours are allowed"}
  validates :category_primary_id, :allow_blank => false, :numericality => { :greater_than => 0, :message => "You must select a primary category"}
  validates :teacher_cost, :allow_blank => true, :numericality => {:equal_to => 0, :message => "You can not be paid for a free class" }, :if => "self.free_lesson=='1'"
  validates :teacher_cost, :allow_blank => true, :numericality => {:greater_than_or_equal_to => 0, :message => "Only positive currencies are allowed" }
  validates :max_attendee, :allow_blank => true, :numericality => {:greater_than => 0, :message => "Number of people must be greater than 0" }
  validates :max_attendee, :allow_blank => true, :numericality => {:only_integer => true, :message => "Only integer number of people are allowed" }
  validates :min_attendee, :allow_blank => true, :numericality => {:greater_than_or_equal_to => 0, :message => "Number of people must be greater than or equal to 0" }
  validates :min_attendee, :allow_blank => true, :numericality => {:only_integer => true, :message => "Only integer number of people are allowed"  }

  def initialize(chalkler)
  	@chalkler = chalkler
    @teacher_id = @chalkler.id
    if @chalkler.channels.length > 0
      @channels = @chalkler.channels
    else
      @channels = [Channel.find(1)]
    end
  end

  def lesson_args
    { "name" => meetup_event_name(@category_primary_id,@title), "teacher_id" => @teacher_id, "lesson_skill" => @lesson_skill, "teacher_bio" => @bio, "do_during_class" => @do_during_class, 
    "learning_outcomes" => @learning_outcomes, "duration" => @duration.to_i*60*60, "cost" => price_calculation(@teacher_cost, Channel.find(@channel_id)), "teacher_cost" => @teacher_cost, 
    "max_attendee" => @max_attendee.to_i, "min_attendee" => @min_attendee.to_i, "availabilities" => @availabilities, "prerequisites" => @prerequisites, 
    "additional_comments" => @additional_comments, "venue" => @venue, "status" => "Unreviewed", "channel_percentage_override" => nil, "chalkle_percentage_override" => nil}
  end

  def submit(params)
    if check_valid_input(params)
      @lesson = Lesson.new(lesson_args)
      if @lesson.save
        @lesson.channels = [Channel.find(@channel_id)]
        @lesson.category_ids = @category_primary_id
      else
        return false
      end
    else
      return false
    end
  end

  def check_valid_input(params)
    @title = params[:title]
    @lesson_skill = params[:lesson_skill]
    @bio = params[:bio]
    @do_during_class = params[:do_during_class]
    @learning_outcomes = params[:learning_outcomes]
    @duration = params[:duration]
    @teacher_cost = params[:teacher_cost]
    @free_lesson = params[:free_lesson]
    @max_attendee = params[:max_attendee]
    @min_attendee = params[:min_attendee]
    @availabilities = params[:availabilities]
    @prerequisites = params[:prerequisites]
    @additional_comments = params[:additional_comments]
    @venue = params[:venue]
    @category_primary_id = params[:category_primary_id].to_i
    if @channels.length > 1
      @channel_id = params[:channel_id].to_i
    else 
      @channel_id = @channels[0].id
    end
    self.valid?
  end

  private

  def price_calculation(teacher_cost,channel)
    (teacher_cost.blank? || channel.teacher_percentage== 0) ? 0: ( teacher_cost.to_d*1.15 / channel.teacher_percentage ).ceil / 1.15 
  end

  def meetup_event_name(category_primary_id,title)
    return ( Category.find(category_primary_id, :select => "name").name + " : " + title )
  end

end
