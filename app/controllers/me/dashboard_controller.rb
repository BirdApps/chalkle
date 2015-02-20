class Me::DashboardController < Me::BaseController
  before_filter :page_titles
  before_filter :header_me
  
  def index
  end

  def settings
  	@chalkler_email_preferences = ChalklerPreferences.new(current_chalkler)
  end

  def bookings
    #TODO: show all bookings for that user
  end

  private
    def page_titles
      @page_title = current_user.name
      @page_subtitle = 'Dashboard'
      @page_title_logo = current_user.avatar
    end

    def header_me
      @nav_links = [{
          img_name: "bolt",
          link: me_root_path,
          active: request.path.include?("index"),
          title: "Dashboard"
        },{
        img_name: "settings",
          link: me_preferences_path,
          active: request.path.include?("show"),
          title: "Settings"
      },
        img_name: "plane", 
        link: me_notification_preference_path,
        active: request.path.include?("notifications"),
        title: "Email Options"
      }]
    end
end
