ActiveAdmin.register Category do
  config.sort_order = "name_asc"

  controller do
    load_resource :except => :index
    authorize_resource
  end

  index do
    column :id
    column :name
    default_actions
  end
end
