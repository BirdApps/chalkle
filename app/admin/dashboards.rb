ActiveAdmin.register_page "Dashboard" do

  menu :priority => 1, :label => proc{ I18n.t("active_admin.dashboard") }

  controller do
    def scoped_collection
      end_of_association_chain.visible.accessible_by(current_ability)
    end
  end

  content :title => proc{ I18n.t("active_admin.dashboard") } do
    columns do
      column do

        panel "Classes for review" do
          table_for Lesson.accessible_by(current_ability).visible.unpublished.order("updated_at asc") do 
            column("Name") {|lesson| link_to(lesson.name, admin_lesson_path(lesson)) }
            column("Teacher") {|lesson| lesson.teacher.present? ? (link_to(lesson.teacher.name, admin_chalkler_path(lesson.teacher))) : "No Teacher" }
            column("Type") {|lesson| lesson.lesson_type }
            column("Category") {|lesson| lesson.category }
            column("Last Update") {|lesson| lesson.updated_at }
            column("Status") {|lesson| lesson.status }
            column("Price") {|lesson| number_to_currency lesson.cost }
          end
        end

        panel "Upcoming classes" do
          table_for Lesson.accessible_by(current_ability).visible.upcoming.order("start_at asc") do
            column("Name") { |lesson| link_to(lesson.name, admin_lesson_path(lesson)) }
            column("Date") { |lesson| lesson.start_at.to_formatted_s(:long) }
            column("Price") { |lesson| number_to_currency lesson.cost }
            column("Teacher cost") { |lesson| number_to_currency lesson.teacher_cost }
            column("Venue cost") { |lesson| number_to_currency lesson.venue_cost }
          end
        end

        if current_admin_user.role=="super"

          panel "Class email task list" do
            table_for Lesson.accessible_by(current_ability).visible.recent.order("start_at asc") do
              column("Name") { |lesson| link_to(lesson.name, admin_lesson_path(lesson)) }
              column("Date") { |lesson| lesson.start_at.to_formatted_s(:long) }
              column("TODO:Pay Reminder") { |lesson| link_to("Email students", admin_lesson_path(lesson)) if lesson.todo_pay_reminder }
              column("TODO:Attendee List") { |lesson| link_to("Email teacher", lesson_email_admin_lesson_path(lesson)) if lesson.todo_attendee_list }
              column("TODO:Payment Summary") { |lesson| link_to("Email teacher", payment_summary_email_admin_lesson_path(lesson)) if lesson.todo_payment_summary }
            end
          end
        end

        panel "Past class performance" do
          table_for Lesson.accessible_by(current_ability).visible.last_week.order("start_at asc") do
            column("Name") { |lesson| link_to(lesson.name, admin_lesson_path(lesson)) }
            column("Group") { |lesson| lesson.groups.collect{|g| g.name}.join(", ") }
            column("Attendance") { |lesson| lesson.attendance}
            if current_admin_user.role=="super"
                column("Income") { |lesson| number_to_currency lesson.income}
            end
          end
        end
      end
    end
  end

end
