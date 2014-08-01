class TheUser
  attr_accessor :chalkler, :admin_user

  def initialize chalkler, admin_user
    @chalkler = chalkler
    @admin_user = admin_user
    @admin_user = AdminUser.find_by_email chalkler.email if @admin_user.nil?
    @chalkler = Chalkler.find_by_email admin_user.email if @chalkler.nil?
  end

  def admin?
    return !@admin_user.nil?
  end

end