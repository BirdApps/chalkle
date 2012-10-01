ActiveAdmin.register Chalkler do
  index do
    column :id
    column :name
    column :meetup_id
    column :email
    column :bio
    default_actions
  end
end
