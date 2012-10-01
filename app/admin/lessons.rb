ActiveAdmin.register Lesson, as: 'Class' do

  index do
    column :id
    column :name
    column :category
    column :teacher
    column :cost
    column :charge
    column :start
    column :end
    default_actions
  end

  show title: :name do |lesson|
    attributes_table do
      row :category 
      row :teacher 
      row :meetup_id do
        link_to lesson.meetup_id, lesson.meetup_data["event_url"]
      end
      row :cost 
      row :bookings do
        "#{lesson.bookings.paid.count} of #{lesson.bookings.confirmed.count} have paid " 
      end
      row :rsvp_list do
        render partial: '/shared/rsvp_list', locals: {bookings: lesson.bookings.confirmed}
      end
      row :kind 
      row :doing 
      row :learn 
      row :skill 
      row :skill_note
      row :bring 
      row :charge 
      row :note 
      row :start 
      row :end 
      row :link 
      row :meetup_data
    end
    active_admin_comments
  end
  
end
