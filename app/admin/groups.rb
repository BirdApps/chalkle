ActiveAdmin.register Group do
  config.sort_order = "name_asc"

  index do
    column :id
    column :name
    default_actions
  end
end