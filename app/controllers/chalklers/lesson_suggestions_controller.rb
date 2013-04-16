class Chalklers::LessonSuggestionsController < Chalklers::BaseController
  def new
    @lesson_suggestion = LessonSuggestion.new
  end

  def create
    @lesson_suggestion = LessonSuggestion.new
    #To get around join table error when creating join with no saved record
    @params = params[:lesson_suggestion]
    @lesson_suggestion.name = @params[:name]
    @lesson_suggestion.description = @params[:description]
    @lesson_suggestion.category_id = @params[:category_id]

    if @lesson_suggestion.save
      @lesson_suggestion.channel_ids = params[:lesson_suggestion][:channel_ids]
      redirect_to root_url, notice: 'Thank you for your suggestion!'
    else
      render :action => "new"
    end
  end
end
