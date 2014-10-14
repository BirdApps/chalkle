class Providers::CourseSuggestionsController < Me::BaseController
  def new
    @course_suggestion = CourseSuggestion.new
  end

  def create
    if params[:course_suggestion][:join_channels]
      params[:course_suggestion][:join_channels].reject!(&:empty?)
    end
    @course_suggestion = CourseSuggestion.new params[:course_suggestion]
    @course_suggestion.chalkler = current_chalkler
    if current_chalkler.channels.count == 1
      @course_suggestion.join_channels = [ current_chalkler.channel_ids ]
    end
    if @course_suggestion.save
      redirect_to :root, notice: 'Thank you for your suggestion!'
    else
      render action: 'new'
    end
  end
end
