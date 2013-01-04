ActiveAdmin.register_page "Trash" do
  menu label: "Trash"

  content do
    @lessons = Lesson.find_all_by_visible false
    @bookings = Booking.find_all_by_visible false
    @payments = Payment.find_all_by_visible false

    panel "Deleted Lessons" do
      table_for @lessons do
        column :id
        column :meetup_id
        column :name
        column :start_at
        column :created_at
        column :actions do |lesson|
          links = "".html_safe
          if can?(:read, lesson)
            links += link_to "View", admin_lesson_path(lesson), :class => "member_link"
          end
          if can?(:unhide, lesson)
            links += link_to "Restore", unhide_admin_lesson_path(lesson), :class => "member_link"
          end
          links
        end
      end
    end

    panel "Deleted Bookings" do
      table_for @bookings do
        column :id
        column :lesson
        column :chalkler
        column :meetup_id
        column :created_at
        column :actions do |booking|
          links = "".html_safe
          if can?(:read, booking)
            links += link_to "View", admin_booking_path(booking), :class => "member_link"
          end
          if can?(:unhide, booking)
            links += link_to "Restore", unhide_admin_booking_path(booking), :class => "member_link"
          end
          links
        end
      end
    end

    panel "Deleted Payments" do
      table_for @payments do
        column :id
        column :reference
        column :xero_contact_name
        column :date
        column :actions do |payment|
          links = "".html_safe
          if can?(:read, payment)
            links += link_to "View", admin_payment_path(payment), :class => "member_link"
          end
          if can?(:unhide, payment)
            links += link_to "Restore", unhide_admin_payment_path(payment), :class => "member_link"
          end
          links
        end
      end
    end
  end
end