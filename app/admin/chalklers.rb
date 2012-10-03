ActiveAdmin.register Chalkler do
  index do
    column :id
    column :name
    column :meetup_id
    column :email
    column :bio
    column :created_at
    default_actions
  end
end
