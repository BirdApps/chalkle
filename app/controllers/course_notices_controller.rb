class CourseNoticesController < ApplicationController
  before_filter :load_course, only: [:show, :create]
  before_filter :load_course_notice, only: [:update, :destroy]
  before_filter :authenticate_chalkler!

  def show
    redirect_to @course
  end

  def create
    params[:course_notice][:chalkler_id] = current_user.id
    notice = CourseNotice.new params[:course_notice]
    notice.course_id = @course.id
    notice.course = @course
    notice.photo = params[:course_notice_photo] if params[:course_notice_photo]
    
    if params[:course_notice_photo].blank? && notice.body.blank?
      return redirect_to channel_course_path(@course.channel.url_name, @course.url_name, @course.id), notice: 'Empty Comment'
    else
      notice.save
    end

    # check if the notice is from the teacher or a chalkler; these are actually different notifications 
    if current_chalkler == @course.teacher.chalkler
      @course.followers_except(current_chalkler).map {|c| c.notify.discussion_from_teacher(notice) }
    else
      @course.teacher.chalkler && @course.teacher.chalkler.notify.discussion_from_chalkler(notice)
      @course.followers_except(current_chalkler).map {|c| c.notify.discussion_from_chalkler(notice) }
    end

    redirect_to channel_course_path(@course.channel.url_name, @course.url_name, @course.id, anchor: 'discuss-'+notice.id.to_s)
  end

  def update
    @course_notice.body = params[:course_notice][:body]
    @course_notice.photo = params[:course_notice_photo] if params[:course_notice_photo]

    if params[:course_notice_photo].blank? && @course_notice.photo.blank? && @course_notice.body.blank?
      return redirect_to delete_course_course_notices_path(@course_notice.course.id, @course_notice.id)
    else
      @course_notice.save
    end

    redirect_to channel_course_path(@course_notice.channel.url_name, @course_notice.course.url_name, @course_notice.course.id, anchor: 'discuss-'+@course_notice.id.to_s)
  end

  def destroy
    @course_notice.visible = !@course_notice.visible
    @course_notice.save
    redirect_to channel_course_path(@course_notice.channel.url_name, @course_notice.course.url_name, @course_notice.course.id, anchor: 'discuss-'+@course_notice.id.to_s)
  end

  private 

    def load_course
      @course = Course.find_by_id(params[:course_id])
      return not_found unless @course
      check_course_visibility
    end

    def load_course_notice
       @course_notice = CourseNotice.find_by_id(params[:id])
      return not_found unless @course_notice
      authorize @course_notice
    end

end