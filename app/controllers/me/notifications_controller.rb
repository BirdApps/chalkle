class Me::NotificationsController < Me::BaseController
  before_filter :page_titles
  before_filter :load_notification, only: [:show]
  
  def index
    @notifications = current_user.notifications.visible.by_date
  end

  def show
    @notification.update_attribute("actioned_at", DateTime.current ) unless @notification.actioned?
    redirect_to @notification.href
  end

  private
    def load_notification
      @notification = Notification.find_by_id(params[:id])
      return not_found unless @notification
      authorize @notification
    end  

    def page_titles
      @page_subtitle = current_user.name
      @page_title = 'Notifications'
      @page_title_logo = current_user.avatar
    end
end