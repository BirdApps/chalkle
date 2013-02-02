class Teaching
  include ActiveAttr::Model

  attr_accessor :lesson, :chalkler, :title, :teacher_id, :bio, :lesson_type, :do_during_class, :learning_outcomes, :duration, :free_lesson, :teacher_cost, :max_attendee, :min_attendee, 
  :suggested_dates, :prerequisites, :anything_else

  validates :title, :presence => { :message => "What we will do during the class can not be blank"}
  validates :do_during_class, :presence => { :message => "What we will do during the class can not be blank"}
  validates :learning_outcomes, :presence => { :message => "What we will learn from the class can not be blank"}
  validates :duration, :allow_blank => true, :numericality => { :greater_than => 0, :message => "Only numbers greater than 0 should be entered here"}
  validates :teacher_cost, :allow_blank => true, :numericality => {:equal_to => 0, :message => "You can not be paid for a free class" }, :if => "self.free_lesson=='1'"
  validates :teacher_cost, :allow_blank => true, :numericality => {:greater_than_or_equal_to => 0, :message => "Only positive currencies are allowed" }
  validates :max_attendee, :allow_blank => true, :numericality => {:greater_than => 0, :message => "Number of people must be greater than 0" }
  validates :min_attendee, :allow_blank => true, :numericality => {:greater_than_or_equal_to => 0, :message => "Number of people must be greater than or equal to 0" }

  def initialize(chalkler)
  	@chalkler = chalkler
  	@teacher_id = @chalkler.id
  	@bio = @chalkler.bio
  end

  def check_valid_input(params)
    self.title = params[:title]
    self.do_during_class = params[:do_during_class]
    self.learning_outcomes = params[:learning_outcomes]
    self.duration = params[:duration]
    self.teacher_cost = params[:teacher_cost]
    self.free_lesson = params[:free_lesson]
    self.max_attendee = params[:max_attendee]
    self.min_attendee = params[:min_attendee]
    self.valid?
  end

  def submit()
  	@lesson = Lesson.new(name: self.title, teacher_id: @teacher_id, duration: self.duration.to_i*60, cost: price_calculation(self.teacher_cost), 
      teacher_cost: self.teacher_cost.to_d)
  	@lesson.save
  end

  def price_calculation(teacher_cost)
    (teacher_cost.blank? ? 0: teacher_cost.to_d*1.20)
  end


end
