ActiveAdmin.register Lesson, as: 'Class' do
  config.sort_order = "created_at_desc"

  index do
    column :id
    column :name
    column :category
    column :teacher
    column :cost
    column :start_at
    column :created_at
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
      row :description
      row :start_at
      row :meetup_data
    end
    active_admin_comments
  end
  
end
