require 'filters/filter'
Filter = Filters::Filter

class FiltersController < ApplicationController
  include Filters::FilterHelpers

  def update
    filter = start_current_chalkler_filter
    filter.overwrite_rule! params[:id], params[:value]
    filter.set_view_type! params[:view]
    back_to_page
  end

  def destroy
    filter = current_chalkler_filter
    if filter
      filter.destroy_rule! params[:id]
      filter.set_view_type! params[:view]
    end
    back_to_page
  end

  def clear
    filter = current_chalkler_filter
    if filter
      filter.clear_rules!
    end
    back_to_page
  end

  def update_view
    filter = start_current_chalkler_filter
    filter.set_view_type! params[:view]
    render nothing: true
  end

  private

    def back_to_page
      redirect_to courses_path
    end
end
