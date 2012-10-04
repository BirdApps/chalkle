ActiveAdmin.register Chalkler do
  config.sort_order = "created_at_desc"
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
