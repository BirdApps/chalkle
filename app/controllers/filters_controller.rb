require 'filters/filter'
Filter = Filters::Filter

class FiltersController < ApplicationController
  include Filters::FilterHelpers

  def update
    filter = start_current_chalkler_filter
    filter.overwrite_rule! params[:id], params[:value]
    filter.set_view_type! params[:view]

    redirect_to lessons_path
  end

  def destroy
    filter = current_chalkler_filter
    if filter
      filter.destroy_rule! params[:id]
      filter.set_view_type! params[:view]
    end

    redirect_to lessons_path
  end

  def update_view
    filter = start_current_chalkler_filter
    filter.set_view_type! params[:view]
    render nothing: true
  end
end
