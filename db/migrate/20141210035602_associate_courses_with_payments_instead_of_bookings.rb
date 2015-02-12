class AssociateCoursesWithPaymentsInsteadOfBookings < ActiveRecord::Migration
  def up
    transaction do
      add_column :courses, :teacher_payment_id, :integer
      add_column :courses, :provider_payment_id, :integer
      Course.reset_column_information

      OutgoingPayment.not_valid.delete_all

      Booking.where("teacher_payment_id IS NOT NULL").each do |booking|
        if booking.course.teacher_payment_id.blank? && booking.teacher_payment_id.present?
          booking.course.update_attribute("teacher_payment_id", booking.teacher_payment_id)
        end
      end

       Booking.where("provider_payment_id IS NOT NULL").each do |booking|
        if booking.course.provider_payment_id.blank? && booking.provider_payment_id.present?
          booking.course.update_attribute("provider_payment_id", booking.provider_payment_id)
        end
      end

      remove_column :bookings, :teacher_payment_id
      remove_column :bookings, :provider_payment_id
    end

  end

  def down
    ActiveRecord::IrreversibleMigration
  end
end
