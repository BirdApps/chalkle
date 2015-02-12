class Sudo::ChalklersController < Sudo::BaseController

  def index
    sort_params = params[:order] || "name ASC"
    @chalklers = Chalkler.order(sort_params)

  end

  def become
    return unless current_user.super?
    sign_in(:chalkler, Chalkler.find(params[:id]), { :bypass => true })
    redirect_to root_path
  end

  def notifications
    @notifications = Notification.by_date
  end

  def csv(role = "provider_admin")
    send_data ProviderAdmin.csv_for(ProviderAdmin.all.uniq_by(&:email)), type: :csv, filename: "provider_admins_#{DateTime.current.strftime('%Y%m%d')}.csv"
  end

end

