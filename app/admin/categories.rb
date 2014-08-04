ActiveAdmin.register Category do
  config.sort_order = "name_asc"
 
  filter :parent


  controller do
    load_resource :except => :index
  end

  index do
    authorized? :index, Category
    column :id
    column :parent_id
    column :name
    column :colour_num
    default_actions
  end
end
