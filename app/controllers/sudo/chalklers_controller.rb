class Sudo::ChalklersController < Sudo::BaseController
  before_filter :authorize_super
  before_filter :set_titles

  def become
    @chalklers = Chalkler.all.take(50)
  end

  def becoming
    return unless current_user.super?
    sign_in(:chalkler, Chalkler.find(params[:id]), { :bypass => true })
    redirect_to root_path
  end
end

