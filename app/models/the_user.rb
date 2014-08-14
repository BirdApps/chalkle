class TheUser

  def initialize current_chalkler, current_admin_user = nil
    @chalkler = current_chalkler
    @admin_user = current_admin_user
    @admin_user = AdminUser.find_by_email chalkler.email if @admin_user.nil? && !@chalkler.nil?
    @chalkler = Chalkler.find_by_email admin_user.email if @chalkler.nil? && !@admin_user.nil?
  end

  def authenticated?
    !!(chalkler || admin_user)
  end

  def role
    admin_user.role if admin_user
  end

  def name
    chalkler.name ? chalkler.name : admin_user.name if authenticated?
  end 

  def chalkler
    @chalkler
  end

  def admin_user
    @admin_user
  end

  def admin?
    !admin_user.nil?
  end

  def chalkler?
    !chalkler.nil?
  end

  def channels
    channel_list = []
    channel_list += admin_user.channels if admin?
    channel_list += chalkler.channels_teachable if admin?
    channel_list
  end
end