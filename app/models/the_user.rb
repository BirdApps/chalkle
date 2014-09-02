class TheUser

  def initialize current_chalkler, current_admin_user = nil
    @chalkler = current_chalkler
    @admin_user = current_admin_user
    @admin_user = AdminUser.find_by_email chalkler.email if @admin_user.nil? && @chalkler.present?
    @chalkler = Chalkler.find_by_email admin_user.email if @chalkler.nil? && @admin_user.present?
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

  def chalkler
    @chalkler
  end

  def admin_user
    @admin_user
  end

  def relation_to(course)
    relationships = []
    relationships << 'channel_admin' if chalkler? && chalkler.channel_admins.where(channel_id: course.channel.id).present?
    relationships << 'teacher' if course.teacher.chalkler.id == chalkler
    relationships << 'attendee' if chalkler? && course.bookings.where( chalkler_id: chalkler.id)
    relationships
  end

  def channels
    channels = []
    channels = channels.concat admin_user.channels if admin?
    channels = channels.concat chalkler.channels_teachable if chalkler?
    channels.uniq
  end
end