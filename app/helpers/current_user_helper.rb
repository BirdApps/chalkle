module CurrentUserHelper
  def current_user
    if @current_user.nil?
      @current_user = TheUser.new current_chalkler, current_admin_user
    end
    return @current_user 
  end
end