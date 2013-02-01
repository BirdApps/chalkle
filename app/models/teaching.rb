class Teaching
  include ActiveAttr::Model

  attr_accessor :lesson, :chalkler, :title, :teacher_id, :bio, :lesson_type, :do_during_class, :learning_outcomes, :duration, :teacher_cost, :max_attendee, :min_attendee, 
  :suggested_times, :prerequisites, :anything_else

  validates :title, :presence => { :message => "What we will do during the class can not be blank"}
  validates :do_during_class, :presence => { :message => "What we will do during the class can not be blank"}
  validates :learning_outcomes, :presence => { :message => "What we will learn from the class can not be blank"}
  validates_numericality_of :duration, :allow_nil => true

  def initialize(chalkler)
  	@chalkler = chalkler
  	@teacher_id = @chalkler.id
  	@bio = @chalkler.bio
  end

  def submit(params)
    self.title = params[:title]
    self.do_during_class = params[:do_during_class]
    self.learning_outcomes = params[:learning_outcomes]
    self.duration = params[:duration]
  	@lesson = Lesson.new(name: self.title, teacher_id: @teacher_id)
  	@lesson.save && self.valid?
  end


end
