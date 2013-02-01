class Teaching
  include ActiveAttr::Model

  attr_accessor :lesson, :chalkler, :name, :teacher_id, :bio, :lesson_type, :do_during_class, :learning_outcomes, :duration, :teacher_cost, :max_attendee, :min_attendee, 
  :suggested_times, :anything_else

  def initialize(chalkler)
  	@chalkler = chalkler
  	@teacher_id = @chalkler.id
  	@bio = @chalkler.bio
  	@lesson = Lesson.new()
  end

  def update_attributes(params)
  	@lesson = Lesson.new(name: params[:name], teacher_id: @teacher_id, duration: params[:duration], teacher_cost: params[:teacher_cost])
  	@lesson.save
  end


end
