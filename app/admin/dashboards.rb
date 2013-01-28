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

        panel "Upcoming classes" do
            table_for Lesson.accessible_by(current_ability).visible.upcoming.order("start_at asc") do 
              column("Name") {|lesson| link_to(lesson.name, admin_lesson_path(lesson)) }
              column("Date") {|lesson| lesson.start_at }
              column("Price") {|lesson| number_to_currency lesson.cost }
              column("Teacher cost") {|lesson| number_to_currency lesson.teacher_cost }
              column("Venue cost") {|lesson| number_to_currency lesson.venue_cost }
            end
        end

        if current_admin_user.role=="super"
            panel "Class email task list" do
                table_for Lesson.accessible_by(current_ability).visible.recent.order("start_at asc") do 
                  column("Name") {|lesson| link_to(lesson.name, admin_lesson_path(lesson)) }
                  column("Date") {|lesson| lesson.start_at}
                  column("TODO:Pay Reminder") {|lesson| link_to("Email students", admin_lesson_path(lesson)) if lesson.TODO_Pay_Reminder }
                  column("TODO:Attendee List") {|lesson| link_to("Email teacher", lesson_email_admin_lesson_path(lesson)) if lesson.TODO_Attendee_List }
                  column("TODO:Payment Summary") {|lesson| link_to("Email teacher", admin_lesson_path(lesson)) if lesson.TODO_Payment_Summary } # to change path to payment summary email after merge
                end
            end
        end

        panel "Past class performance" do
            table_for Lesson.accessible_by(current_ability).visible.last_week.order("start_at asc") do 
                column("Name") {|lesson| link_to(lesson.name, admin_lesson_path(lesson)) }
                column("Group") {|lesson| lesson.groups.collect{|g| g.name}.join(", ") }
                column("Attendance") {|lesson| lesson.attendance}
                if current_admin_user.role=="super"
                    column("Income") {|lesson| number_to_currency lesson.collected_revenue} # subtract teacher payment after that has been merged
                    column("Potential Writeoff") {|lesson| number_to_currency lesson.uncollected_revenue}
                end
            end
        end

      end
    end

  end # content
end
