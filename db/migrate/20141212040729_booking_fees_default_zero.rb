class BookingFeesDefaultZero < ActiveRecord::Migration
  def change
    change_column_null :bookings, :chalkle_fee, false, 0
    change_column_null :bookings, :chalkle_gst, false, 0
    change_column_null :bookings, :teacher_fee, false, 0
    change_column_null :bookings, :teacher_gst, false, 0
    change_column_null :bookings, :provider_fee, false, 0
    change_column_null :bookings, :provider_gst, false, 0
    change_column_null :bookings, :processing_fee, false, 0
    change_column_null :bookings, :processing_gst, false, 0
  end
end
