ActiveAdmin.register Chalkler do
  config.sort_order = "created_at_desc"

  controller do
    load_resource :except => :index
    authorize_resource

    def create
      @chalkler = Chalkler.new(bio: params[:chalkler][:bio], email: params[:chalkler][:email], gst: params[:chalkler][:gst],
        meetup_id: params[:chalkler][:meetup_id], name: params[:chalkler][:name])
      if @chalkler.save && current_admin_user.channels.any?
        @chalkler.channels << current_admin_user.channels.first
        update!
      else
        redirect_to :back
      end
    end
  end

  filter :channels_name, :as => :select, :label => "Channel",
    :collection => proc{ current_admin_user.channels.collect{ |c| [c.name, c.name] }}
  filter :meetup_id
  filter :name
  filter :email

  index do
    column :id
    column :name
    column :channels do |chalkler|
      chalkler.channels.collect{|c| c.name}.join(", ")
    end
    column :meetup_id do |chalkler|
      if chalkler.meetup_data.present?
        link_to chalkler.meetup_id, chalkler.meetup_data["link"]
      else
        "non-meetup"
      end
    end
    column :email
    column :bio
    column :created_at
    default_actions
  end

  show title: :name do |chalkler|
    attributes_table do
      row :name
      row :id
      row :meetup_id do
        if chalkler.meetup_data.present?
          link_to chalkler.meetup_id, chalkler.meetup_data["link"]
        else
          "non-meetup"
        end
      end
      row :email
      row :email_frequency
      row "Email categories" do
        if chalkler.email_categories.present?
          chalkler.email_categories.collect{|c| Category.find(c,:select => :name).name}.join(", ")
        else
          "No email categories selected"
        end
      end
      row "Email streams" do
        if chalkler.email_streams.present?
          chalkler.email_streams.collect{|c| Stream.find(c,:select => :name).name}.join(", ")
        else
          "No email streams selected"
        end
      end
      row :gst
      row :bio
      row :teaching do
        render partial: "/admin/chalklers/lessons", locals: { lessons: chalkler.lessons_taught }
      end
      row :lessons do
        render partial: "/admin/chalklers/lessons", locals: { lessons: chalkler.lessons }
      end
      if current_admin_user.role=="super"
        row :meetup_data
      end
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end

  form do |f|
    f.inputs :details do
      f.input :name
      f.input :meetup_id
      f.input :email
      f.input :gst
      f.input :bio
    end
    f.actions
  end
end
