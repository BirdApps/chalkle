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

        if current_admin_user.role=="super"
          panel "Partner Inquiries" do
            table_for PartnerInquiry.accessible_by(current_ability).order("created_at asc").where( 'created_at > ?', Date.today-1.week ) do
              column("Name") { |partner_inquiry| link_to(partner_inquiry.name, admin_partner_inquiry_path(partner_inquiry)) }
              column("Inquiry Date") { |partner_inquiry| partner_inquiry.created_at.to_formatted_s(:long) }
              column("Contact Details") { |partner_inquiry| partner_inquiry.contact_details }
            end
          end

        end

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
          table_for Lesson.accessible_by(current_ability).upcoming(10.days.from_now).order("start_at asc") do
            column("Attention") { |lesson| status_tag( (lesson.flag_warning ? lesson.flag_warning : "OK"), (lesson.flag_warning ? :error : :ok)  ) }
            column("Name") { |lesson| link_to(lesson.name, admin_lesson_path(lesson)) }
            column("Date") { |lesson| lesson.start_at.to_formatted_s(:long) }
            column("Advertised Price") { |lesson| number_to_currency (lesson.cost.present? ? lesson.cost : nil) }
            column("RSVPs") { |lesson| lesson.attendance}
            column("Min Attendee") { |lesson| lesson.min_attendee }
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
