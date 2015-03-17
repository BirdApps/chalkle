class RewriteNotificationHrefs < ActiveRecord::Migration
  def up
    Notification.transaction do
      results = Notification.scoped.map do |notification|
        begin
          if notification.target.present?
            target = notification.target
            new_url = case target.class.name
            when "Booking"
              provider_course_path target.course.path_params
            when "Course"
              provider_course_path target.path_params
            when "Chalkler"
              chalkler_path target
            when "CourseNotice"
              provider_course_path target.course.path_params
            else
              notification.href
            end
            if notification.href != target
              notification.href = target
              notification.save
              target
            else
              nil
            end
          end
        rescue
          next
        end
      end
      puts "#{results.compact.count} notification links updated"
    end
  end

  def down
    ActiveRecord::IrreversibleMigration
  end
end
