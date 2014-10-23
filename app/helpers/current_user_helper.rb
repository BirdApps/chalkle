module CurrentUserHelper
  def current_user
    if @current_user.nil?
      @current_user = TheUser.new current_chalkler
    end
    return @current_user 
  end
end