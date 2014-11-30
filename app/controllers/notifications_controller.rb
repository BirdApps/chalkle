class NotificationsController < ApplicationController
  before_filter :load_notification, only: [:show]
  
  def index

  end

  def show
    if @notification.chalkler == current_chalkler 
      @notification.update_attribute("actioned_at", DateTime.current ) unless !@notification.actioned?
    end
    redirect_to @notification.href
  end

  private
    def load_notification
      @notification = Notification.find_by_id(params[:id])
      return not_found unless @notification
      authorize @notification
    end  
end