class TheUser

  def initialize current_chalkler, current_admin_user = nil
    @chalkler = current_chalkler || Chalkler.new
    @admin_user = current_admin_user || AdminUser.new
    @admin_user = AdminUser.find_by_email chalkler.email if @admin_user.id.nil? && @chalkler.id.present?
    @chalkler = Chalkler.find_by_email admin_user.email if @chalkler.id.nil? && @admin_user.id.present?
  end

  def authenticated?
    !!(chalkler || admin_user)
  end

  def admin?
    !admin_user.nil?
  end

  def chalkler?
    !chalkler.nil?
  end

  def role
    admin_user.role if admin_user
  end

  def name
    chalkler.name ? chalkler.name : admin_user.name if authenticated?
  end 

  def email
    chalkler.email ? chalkler.email : admin_user.email if authenticated?
  end

  def chalkler
    @chalkler
  end

  def admin_user
    @admin_user
  end

  def super?
    admin_user.present? ? admin_user.super? : false
  end

  def channels_adminable
    chalkler.id.present? ? chalkler.channels_adminable : []
  end

  def channels
    channels = []
    channels = channels.concat admin_user.channels if admin?
    channels = channels.concat chalkler.channels_teachable if chalkler?
    channels.uniq
  end
end