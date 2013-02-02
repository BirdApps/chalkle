class Teaching
  include ActiveAttr::Model

  attr_accessor :lesson, :chalkler, :title, :teacher_id, :bio, :lesson_type, :do_during_class, :learning_outcomes, :duration, :free_lesson, :teacher_cost, :max_attendee, :min_attendee, 
  :suggested_dates, :prerequisites, :anything_else

  validates :title, :presence => { :message => "Title of class can not be blank"}
  validates :teacher_id, :presence => { :message => "You must be registered with chalkle first"}
  validates :do_during_class, :presence => { :message => "What we will do during the class can not be blank"}
  validates :learning_outcomes, :presence => { :message => "What we will learn from this class can not be blank"}
  validates :duration, :allow_blank => true, :numericality => { :only_integer => true, :message => "Only integer number of minutes are allowed"}
  validates :teacher_cost, :allow_blank => true, :numericality => {:equal_to => 0, :message => "You can not be paid for a free class" }, :if => "self.free_lesson=='1'"
  validates :teacher_cost, :allow_blank => true, :numericality => {:greater_than_or_equal_to => 0, :message => "Only positive currencies are allowed" }
  validates :max_attendee, :allow_blank => true, :numericality => {:greater_than => 0, :message => "Number of people must be greater than 0" }
  validates :max_attendee, :allow_blank => true, :numericality => {:only_integer => true, :message => "Only integer number of people are allowed" }
  validates :min_attendee, :allow_blank => true, :numericality => {:greater_than_or_equal_to => 0, :message => "Number of people must be greater than or equal to 0" }
  validates :min_attendee, :allow_blank => true, :numericality => {:only_integer => true, :message => "Only integer number of people are allowed"  }

  def initialize(chalkler)
  	@chalkler = chalkler
    @teacher_id = @chalkler.id
    @bio = @chalkler.bio
  end

  def check_valid_input(params)
    @title = params[:title]
    @lesson_type = params[:lesson_type]
    @bio = params[:bio]
    @do_during_class = params[:do_during_class]
    @learning_outcomes = params[:learning_outcomes]
    @duration = params[:duration]
    @teacher_cost = params[:teacher_cost]
    @free_lesson = params[:free_lesson]
    @max_attendee = params[:max_attendee]
    @min_attendee = params[:min_attendee]
    self.valid?
  end

  def submit(params)
    if check_valid_input(params)
      @lesson = Lesson.new(name: @title, teacher_id: @teacher_id, lesson_type: @lesson_type, teacher_bio: @bio, do_during_class: @do_during_class, 
        learning_outcomes: @learning_outcomes, duration: @duration.to_i*60, cost: price_calculation(@teacher_cost), teacher_cost: @teacher_cost, 
        max_attendee: @max_attendee.to_i, min_attendee: @min_attendee.to_i, status: "Unreviewed")
      @lesson.save
    else
      return false
    end
  end

  def price_calculation(teacher_cost)
    (teacher_cost.blank? ? 0: teacher_cost.to_d*1.20)
  end


end
