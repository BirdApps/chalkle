FactoryGirl.define do
  factory :booking do
    name 'Joe Groot'
    status 'yes'
    payment_method 'credit_card'
    payment {|i| i.association(:payment) }
    chalkler { |i| i.association(:chalkler)}
    course { |i| i.association(:fee_per_attendee_course)}
    
    teacher_fee     8.50
    teacher_gst     1.50
    provider_fee     5.87
    provider_gst     1.03
    chalkle_fee     2.00
    chalkle_gst     0.30
    processing_fee  0.68
    processing_gst  0.12


    factory :cancelled_booking do
      status 'no'
    end

    factory :pending_refund do
      status 'refund_pending'
    end
  end

  factory :booking_free do
    name 'Joe Groot'
    status 'yes'
    payment_method 'free'
    chalkler { |i| i.association(:chalkler)}
    course { |i| i.association(:course)}
  end

end
