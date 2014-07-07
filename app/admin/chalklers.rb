ActiveAdmin.register Chalkler do
  config.sort_order = "created_at_desc"

  scope :teachers

  controller do
    load_resource :except => :index
    authorize_resource

    def create
      params[:chalkler][:join_channels].reject!(&:empty?) if params[:chalkler][:join_channels]
      @chalkler = Chalkler.new(params[:chalkler], :as => :admin)
      @chalkler.set_password_token = true
      if current_admin_user.channels.count == 1
        @chalkler.join_channels = [current_admin_user.channel_ids]
      end
      create!
    end
  end

  filter :channels_name, :as => :select, :label => "Channel",
    :collection => proc{ 
      if current_admin_user.super?
        Channel.all.map {|c| [c.name, c.name ]}
      else
        current_admin_user.channels.collect{ |c| [c.name, c.name] }
      end
    }

  filter :meetup_id
  filter :name
  filter :email

  index do
    column :id
    column :name

    if current_admin_user.super?
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
    end

    column "Last login" do |chalkler|
      if chalkler.current_sign_in_at?
        "#{time_ago_in_words chalkler.current_sign_in_at} ago"
      else
        "never"
      end
    end
    column :email
    column "Comments" do |chalkler|
      (comment = ActiveAdmin::Comment.where{(resource_type.eq "Chalkler") & (resource_id.eq chalkler.id.to_s)}.order("created_at").last).nil? ? nil : comment.body
    end
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
      row "Channels" do
        chalkler.channels.collect{|c| c.name}.join(", ")
      end
      row "Last login" do
        if chalkler.current_sign_in_at?
          "#{time_ago_in_words chalkler.current_sign_in_at} ago"
        else
          "never"
        end
      end
      row :email
      row :phone_number
      row :email_frequency
      row "Email categories" do
        if chalkler.email_categories.present?
          chalkler.email_categories.collect{|c| Category.find(c,:select => :name).name}.join(", ")
        else
          "No email categories selected"
        end
      end
      row :bio
      row :teaching do
        render partial: "/admin/chalklers/courses", locals: { courses: chalkler.courses_taught }
      end
      row :courses do
        render partial: "/admin/chalklers/courses", locals: { courses: chalkler.courses.where{bookings.status.eq 'yes'} }
      end
      if current_admin_user.role=="super"
        row :meetup_data
      end
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end

  action_item(:only => :show, if: proc{ can?(:send_reset_password_mail, resource) && chalkler.email? }) do
    link_to 'Send password reset email', send_reset_password_mail_admin_chalkler_path(resource),
      :data => { :confirm => "Are you sure you want to send password reset instructions?" }
  end

  member_action :send_reset_password_mail do
    chalkler = Chalkler.find params[:id]
    if chalkler.send_reset_password_instructions
      flash[:notice] = 'Password reset instructions have been sent!'
    else
      flash[:warn] = 'Could not send password reset instructions!'
    end
    redirect_to :back
  end

  form do |f|
    f.inputs :details do
      f.input :name
      if current_admin_user.administerable_channels.size > 1
        if f.object.new_record?
          f.input :join_channels, :label => 'Channels', :as => :check_boxes, :collection => current_admin_user.administerable_channels
        else
          f.input :channels, :as => :check_boxes, :label => 'Channels', :collection => current_admin_user.administerable_channels
        end
      end

      f.input :email_regions, :label => 'Region', :as => :check_boxes, :collection => Region.all if current_admin_user.super?


      if current_admin_user.super? || f.object.new_record?
        if f.object.new_record?
          f.input :email, :hint => 'User will receive password reset email if entered'
        else
          f.input :email
        end
      end
      f.input :phone_number
      f.input :bio
    end
    f.actions
  end

  controller do 
    def update
      @chalkler = Chalkler.find(params[:id])

      params[:chalkler][:channel_ids].concat(
        @chalkler.channels.map(&:id) - current_admin_user.administerable_channels.map(&:id)
      ) if params[:chalkler][:channel_ids]
      

      update! as: :admin
    end
  end

end
