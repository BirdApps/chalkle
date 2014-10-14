class CategoriesController < ApplicationController

  def index
    @categories = Category.ordered
  end

  def show
    not_found if !@category
  end

end