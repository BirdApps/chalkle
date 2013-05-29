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

        panel "Unreviewed classes" do
          render partial: "/admin/dashboard/lesson_panel", locals: {lessons: Lesson.accessible_by(current_ability).visible.unreviewed.order("updated_at asc")}
        end

        panel "Classes being processed" do
          render partial: "/admin/dashboard/lesson_panel", locals: {lessons: Lesson.accessible_by(current_ability).visible.processing.order("updated_at asc")}
        end

        panel "On-hold classes" do
          render partial: "/admin/dashboard/lesson_panel", locals: {lessons: Lesson.accessible_by(current_ability).visible.on_hold.order("updated_at asc")}
        end

        panel "Approved classes" do
          render partial: "/admin/dashboard/lesson_panel", locals: {lessons: Lesson.accessible_by(current_ability).visible.approved.order("updated_at asc")}
        end


        panel "Coming up this week" do
          table_for Lesson.accessible_by(current_ability).upcoming(7.days.from_now).order("start_at asc") do
            column("Name") { |lesson| link_to(lesson.name, admin_lesson_path(lesson)) }
            column("Date") { |lesson| lesson.start_at.to_formatted_s(:long) }
            if current_admin_user.role == "super"
              column("Price") { |lesson| number_to_currency lesson.cost }
              column("Teacher cost") { |lesson| number_to_currency lesson.teacher_cost }
              column("Venue cost") { |lesson| number_to_currency lesson.venue_cost }
            else
              column("Advertised Price") { |lesson| number_to_currency (lesson.cost.present? ? lesson.cost : nil) }
              column("Attendee") { |lesson| lesson.attendance}
              column("Min Attendee") { |lesson| lesson.min_attendee }
            end
            column("May Cancel") { |lesson| link_to("Email them", admin_lesson_path(lesson)) if lesson.class_may_cancel }
          end
        end

        if current_admin_user.role=="super"
          panel "Class email task list" do
            table_for Lesson.accessible_by(current_ability).visible.recent.published.order("start_at asc") do
              column("Name") { |lesson| link_to(lesson.name, admin_lesson_path(lesson)) }
              column("Date") { |lesson| lesson.start_at.to_formatted_s(:long) }
              column("TODO:Pay Reminder") { |lesson| link_to("Email students", admin_lesson_path(lesson)) if lesson.todo_pay_reminder }
              column("TODO:Attendee List") { |lesson| link_to("Email teacher", lesson_email_admin_lesson_path(lesson)) if lesson.todo_attendee_list }
              column("TODO:Payment Summary") { |lesson| link_to("Email teacher", payment_summary_email_admin_lesson_path(lesson)) if lesson.todo_payment_summary }
            end
          end

        end

      end
    end
  end

end
