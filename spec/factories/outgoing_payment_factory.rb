FactoryGirl.define do
  factory :outgoing_payment do
    status "pending"
    courses { |i| [i.association(:course)]}
    channel { |i| i.association(:channel) }
    teacher { |i| i.association(:channel_teacher) }

    factory :paid_outgoing_payment do
      status        'marked_paid'
      fee           127.5
      tax           22.5
      tax_number    '1234'
      bank_account  '1234567'
      reference     'ref345'
      paid_date     DateTime.current - 2.days
    end

  end
end