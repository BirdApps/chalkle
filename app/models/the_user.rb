class TheUser
  attr_accessor :chalkler, :admin_user

  def initialize chalkler
    @chalkler = chalkler
    @admin_user = AdminUser.find_by_email chalkler.email
  end

  def admin?
    return !@admin_user.nil?
  end

end