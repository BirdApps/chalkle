class CourseNoticesController < ApplicationController
  before_filter :load_course, only: :create
  before_filter :authenticate_chalkler!

  def create

  end

  def update

  end

  def destroy

  end

end