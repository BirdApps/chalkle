class Chalklers::LessonSuggestionsController < Chalklers::BaseController
  def new
    @lesson_suggestion = LessonSuggestion.new
  end

  def create
    @lesson_suggestion = LessonSuggestion.new(params[:lesson_suggestion])
    @lesson_suggestion.channel_ids = params[:lesson_suggestion][:channel_ids]
     
    if @lesson_suggestion.save
      redirect_to root_url, notice: 'Thank you for your suggestion!'
    else
      puts @lesson_suggestion.inspect
      render :action => "new"
    end
  end
end
