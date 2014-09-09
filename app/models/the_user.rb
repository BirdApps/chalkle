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

  def chalkler
    @chalkler
  end

  def admin_user
    @admin_user
  end

  def relation_to(course)
    relationships = []
    relationships << :channel_admin if chalkler? && chalkler.channel_admins.where(channel_id: course.channel_id).present?
    relationships << :teacher if course.teacher.chalkler.id == chalkler
    relationships << :attendee if chalkler? && course.bookings.where( chalkler_id: chalkler.id)
    relationships
  end

  def has_relation(course, relationships)
    true if (relation_to(course) & relationships).count > 0
  end

  def channels
    channels = []
    channels = channels.concat admin_user.channels if admin?
    channels = channels.concat chalkler.channels_teachable if chalkler?
    channels.uniq
  end
end