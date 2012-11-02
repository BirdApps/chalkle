ActiveAdmin.register Category do
  config.sort_order = "name_asc"

  # filter :categories_groups_name, :as => :select,
    # :collection => Group.all.collect{|g| [g.name, g.name]}, :label => "Group"

  index do
    column :id
    column :name
    column :groups do |category|
      category.groups.collect{|g| g.name}.join(", ")
    end
    default_actions
  end
end
