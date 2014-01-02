require 'filters/filter'
Filter = Filters::Filter

class FiltersController < ApplicationController
  def update
    if current_chalkler
      filter = current_chalkler.lesson_filter || current_chalkler.create_lesson_filter
      filter.overwrite_rule! params[:id], params[:value]
    end

    redirect_to lessons_path
  end

  def destroy
    if current_chalkler
      filter = current_chalkler.lesson_filter || current_chalkler.create_lesson_filter
      filter.destroy_rule! params[:id]
    end

    redirect_to lessons_path
  end

end
