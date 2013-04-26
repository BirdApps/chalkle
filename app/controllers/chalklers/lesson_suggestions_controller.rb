class Chalklers::LessonSuggestionsController < Chalklers::BaseController
  def new
    @lesson_suggestion = LessonSuggestion.new
  end

  def create
    @lesson_suggestion = LessonSuggestion.new(params[:lesson_suggestion])
    @lesson_suggestion.chalkler = current_chalkler
    if @lesson_suggestion.save
      redirect_to root_url, notice: 'Thank you for your suggestion!'
    else
      render :action => "new"
    end
  end
end
