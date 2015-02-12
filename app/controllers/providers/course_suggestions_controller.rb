class Providers::CourseSuggestionsController < Me::BaseController
  def new
    @course_suggestion = CourseSuggestion.new
  end

  def create
    if params[:course_suggestion][:join_providers]
      params[:course_suggestion][:join_providers].reject!(&:empty?)
    end
    @course_suggestion = CourseSuggestion.new params[:course_suggestion]
    @course_suggestion.chalkler = current_chalkler
    if current_chalkler.providers.count == 1
      @course_suggestion.join_providers = [ current_chalkler.provider_ids ]
    end
    if @course_suggestion.save
      redirect_to :root, notice: 'Thank you for your suggestion!'
    else
      render action: 'new'
    end
  end
end
