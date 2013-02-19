ActiveAdmin.register Category do
  config.sort_order = "name_asc"

  controller do
    load_resource :except => :index
    authorize_resource
  end

  index do
    column :id
    column :name
    column :channels do |category|
      category.channels.collect{|c| c.name}.join(", ")
    end
    default_actions
  end
end
