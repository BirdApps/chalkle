ActiveAdmin.register Chalkler do
  config.sort_order = "created_at_desc"
  index do
    column :id
    column :name
    column :meetup_id do
      link_to chalkler.meetup_id, chalkler.meetup_data["link"]
    end
    column :email
    column :bio
    column :created_at
    default_actions
  end
  show title: :name do |chalkler|
    attributes_table do
      row :name
      row :id
      row :meetup_id do
        link_to chalkler.meetup_id, chalkler.meetup_data["link"]
      end
      row :email
      row :bio
      row :teaching do
        raw chalkler.lessons_taught.collect{|l| link_to "#{l.name} - #{l.start_at}", admin_class_path(l)}.join('<br/> ')
      end
      row :lessons do
        raw chalkler.lessons.collect{|l| link_to "#{l.name} - #{l.start_at}", admin_class_path(l)}.join('<br/ ')
      end
      row :meetup_data
      row :created_at
      row :updated_at
    end
  end
end
