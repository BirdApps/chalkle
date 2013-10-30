ActiveAdmin.register Category do
  config.sort_order = "name_asc"

  controller do
    load_resource :except => :index
    authorize_resource
  end

  index do
    column :id
    column :parent_id
    column :name
    column :colour_num
    default_actions
  end
end
