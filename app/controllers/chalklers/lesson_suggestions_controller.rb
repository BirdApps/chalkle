class Chalklers::LessonSuggestionsController < Chalklers::BaseController
  def new
    @lesson_suggestion = LessonSuggestion.new
  end

  def create
    @lesson_suggestion = LessonSuggestion.new
    @lesson_suggestion.name = @params[:lesson_suggestion][:name]
    @lesson_suggestion.description = @params[:lesson_suggestion][:description]
    @lesson_suggestion.category_id = @params[:lesson_suggestion][:category_id]

    if @lesson_suggestion.save
      @lesson_suggestion.channel_ids = params[:lesson_suggestion][:channel_ids]
      redirect_to root_url, notice: 'Thank you for your suggestion!'
    else
      render :action => "new"
    end
  end
end
