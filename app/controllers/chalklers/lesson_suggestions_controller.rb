class Chalklers::LessonSuggestionsController < Chalklers::BaseController
  def new
    @lesson_suggestion = LessonSuggestion.new
  end

  def create
    if params[:lesson_suggestion][:join_channels]
      params[:lesson_suggestion][:join_channels].reject!(&:empty?)
    end
    @lesson_suggestion = LessonSuggestion.new(params[:lesson_suggestion])
    @lesson_suggestion.chalkler = current_chalkler
    if current_chalkler.channels.count == 1
      @lesson_suggestion.join_channels = [ current_chalkler.channel_ids ]
    end
    if @lesson_suggestion.save
      redirect_to root_url, notice: 'Thank you for your suggestion!'
    else
      render :action => "new"
    end
  end
end
