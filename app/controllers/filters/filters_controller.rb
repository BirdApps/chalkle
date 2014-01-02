module Filters
  class FiltersController < ApplicationController
    def create
      if current_chalkler
        filter = current_chalkler.lesson_filter || current_chalkler.create_lesson_filter
        filter.overwrite_rule! params[:type], params[:value]
      end

      redirect_to lessons_path
    end
  end
end