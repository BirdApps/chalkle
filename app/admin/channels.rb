ActiveAdmin.register Channel do
  config.sort_order = "name_asc"

  controller do
    load_resource :except => :index
    authorize_resource
  end

  index do
    column :id
    column :name
    column :url_name
    column :channel_percentage do |channel|
      number_to_percentage(channel.channel_percentage*100, :precision => 2)
    end
    column :teacher_percentage do |channel|
      number_to_percentage(channel.teacher_percentage*100, :precision => 2)
    end
    default_actions
  end

  show title: :name do |channel|
    attributes_table do
      row :name
      row :url_name
      row "Percentage of revenue going to channel" do |channel|
        number_to_percentage(channel.channel_percentage*100, :precision => 2)
      end
      row "Percentage of revenue going to teacher" do |channel|
        number_to_percentage(channel.teacher_percentage*100, :precision => 2)
      end
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end
end
