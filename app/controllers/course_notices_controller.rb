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
    notice.course = @course
    notice.photo = params[:course_notice_photo] if params[:course_notice_photo]
    
    if params[:course_notice_photo].blank? && notice.body.blank?
      return redirect_to provider_course_path(@course.provider.url_name, @course.url_name, @course.id), notice: t('flash.discussion.error')
    else
      notice.save
    end

    role = current_chalkler == @course.teacher.chalkler ? :teacher : :chalkler
    Notify.for(notice).as(role).from(current_chalkler).created

    redirect_to provider_course_path(@course.provider.url_name, @course.url_name, @course.id, anchor: 'discuss-'+notice.id.to_s)
  end

  def update
    @course_notice.body = params[:course_notice][:body]
    @course_notice.photo = params[:course_notice_photo] if params[:course_notice_photo]

    if params[:course_notice_photo].blank? && @course_notice.photo.blank? && @course_notice.body.blank?
      destroy and return
    else
      @course_notice.save
    end

    redirect_to provider_course_path(@course_notice.course.path_params({ anchor: 'discuss-'+@course_notice.id.to_s }))
  end

  def destroy
    @course_notice.visible = !@course_notice.visible
    @course_notice.save
    redirect_to provider_course_path(@course_notice.provider.url_name, @course_notice.course.url_name, @course_notice.course.id, anchor: 'discuss-'+@course_notice.id.to_s) and return
  end

  private 

    def load_course_notice
       @course_notice = CourseNotice.find_by_id(params[:id])
      return not_found unless @course_notice
      authorize @course_notice
    end

end