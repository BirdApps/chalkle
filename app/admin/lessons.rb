ActiveAdmin.register Lesson do #, as: 'Class' do
  config.sort_order = "created_at_desc"

  filter :groups_name, :as => :select, :label => "Group",
    :collection => proc{ current_admin_user.groups.collect{ |g| [g.name, g.name] }}
  filter :name
  filter :category
  filter :teacher
  filter :cost
  filter :start_at

  index do
    column :id
    column :name
    column :groups do |lesson|
      lesson.groups.collect{|g| g.name}.join(", ")
    end
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
      row :teacher_cost
      row :venue_cost
      row :start_at
      row :duration
      row :bookings do
        "#{lesson.bookings.paid.count} of #{lesson.bookings.confirmed.count} have paid "
      end
      row :rsvp_list do
        render partial: '/shared/rsvp_list', locals: {bookings: lesson.bookings.confirmed}
      end
      row :description do
        simple_format lesson.description
      end
      row :meetup_data
    end
    active_admin_comments
  end

  form do |f|
    f.inputs :details do
      f.input :name
      f.input :category
      f.input :teacher
      f.input :cost
      f.input :teacher_cost
      f.input :venue_cost
      f.input :start_at
      f.input :duration
      f.input :description
    end
    f.buttons
  end
end
