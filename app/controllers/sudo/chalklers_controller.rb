class Sudo::ChalklersController < Sudo::BaseController
  before_filter :set_titles

  def index
  end

  def become
    sort_params = params[:order] || "name ASC"
    @chalklers = Chalkler.order(sort_params)

  end

  def becoming
    return unless current_user.super?
    sign_in(:chalkler, Chalkler.find(params[:id]), { :bypass => true })
    redirect_to root_path
  end

  def notifications
    @notifications = Notification.by_date
  end

end

