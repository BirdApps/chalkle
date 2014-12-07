FactoryGirl.define do

  factory :channel_teacher, aliases: [:teacher] do
    chalkler { |i| i.association(:chalkler) }
    channel { |i| i.association(:channel) }
    #courses { |i| [ i.association(:course) ] }

    email { generate(:email) }
    pseudo_chalkler_email { generate(:email) }
    bio "All about me!!"
    can_make_classes true
    tax_number '123123'
    account '123456789'
  end

end
