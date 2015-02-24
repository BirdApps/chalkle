class Me::BaseController < ApplicationController
  before_filter :authenticate_chalkler!
  before_filter :page_titles
  before_filter :header_chalkler

  private
    def page_titles
      @page_title = current_user.name
      @page_subtitle = 'Dashboard'
      @page_title_logo = current_user.avatar
    end

end
