FactoryGirl.define do

  factory :provider_teacher, aliases: [:teacher] do

    email { generate(:email) }
    pseudo_chalkler_email { generate(:email) }
    bio "All about me!!"
    can_make_classes true
    tax_number '123123'
    account '123456789'

    provider { |i| i.association(:provider) }
    chalkler { |i| i.association(:teacher_chalkler) }
    
  end

end
