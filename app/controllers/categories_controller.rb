class CategoriesController < ApplicationController

  before_filter :load_category

  def index
    @categories = Category.ordered
  end

  def show
    not_found if !@category
  end

  private 

  def load_category
    @category = Category.includes(:courses).find_by_url_name params[:category_url_name] if params[:category_url_name]
  end
end