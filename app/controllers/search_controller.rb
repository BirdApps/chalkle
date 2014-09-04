class SearchController < ApplicationController
  def index
    classes
  end

  def classes
    @courses = []
    query = params[:q]
    courses = Course.arel_table
    if query
      query_parts = query.split.map { |part| "%#{part}%" }
      @courses = Course.where courses[:name].matches_any(query_parts)
    end
    render :classes
  end
end