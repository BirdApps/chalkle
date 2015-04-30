class CoursePolicy < ApplicationPolicy
  attr_reader :user, :course

  def initialize(user, course)
    @user = user
    @course = course
  end

  def tiny_url?
    true
  end

  def bookings? 
    read? 
  end

  def bookings_csv?
    read?
  end

  def show?
    read? or Course::PUBLIC_STATUSES.include?(@course.status)
  end

  def update?
    edit?
  end

  def new?
    (@user.provider_teachers & @course.provider.provider_teachers.where(can_make_classes: true)).present?
  end

  def create?
    new?
  end


  def edit?
    @course.editable? && write?
  end

  def clone?
    write?(true)
  end

  def change_status?
    user_provider_teachers = (@user.provider_teachers & @course.provider.provider_teachers)
    teacher_write = user_provider_teachers.present? && user_provider_teachers.select{|c| c.can_make_classes? }
    write? or teacher_write
  end

  def confirm_cancel?
    @course.cancellable? && write?
  end

  def cancel?
    write?
  end

  def admin?
    @user.super? or @user.provider_admins.where(provider_id: @course.provider_id).present?
  end

  def write?(anytime=false)
    anytime = true if @course.status == "Preview"
    @user.super? or
     ((@user.provider_teachers.where(id: @course.teacher_id, can_make_classes: true).present? or 
      @user.provider_admins.where(provider_id: @course.provider_id).present?) and 
      (anytime ? true : (@course.end_at || @course.start_at) > DateTime.current))
  end

  def read?
    @user.super? or @user.provider_teachers.where(provider_id: @course.provider_id).present? or @user.provider_admins.where(provider_id: @course.provider_id).present?
  end
end