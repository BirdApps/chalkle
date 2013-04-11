ActiveAdmin.register Chalkler do
  config.sort_order = "created_at_desc"

  controller do
    load_resource :except => :index
    authorize_resource

    def create
      if(params[:chalkler][:channel_ids].is_a?(String) && params[:chalkler][:channel_ids].empty?) ||
        (params[:chalkler][:channel_ids].is_a?(Array) && params[:chalkler][:channel_ids].reject(&:empty?).empty?)
        flash[:error] = "Chalkler must belong to a channel"
        redirect_to :back
        return
      end
      @chalkler = Chalkler.new(bio: params[:chalkler][:bio], email: params[:chalkler][:email], gst: params[:chalkler][:gst],
        meetup_id: params[:chalkler][:meetup_id], name: params[:chalkler][:name])
      if @chalkler.save
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
    column "Last login" do |chalkler|
      if chalkler.current_sign_in_at?
        "#{time_ago_in_words chalkler.current_sign_in_at} ago"
      else
        "never"
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
      row :email_frequency
      # row "Email categories" do
        # if chalkler.email_categories.present?
          # chalkler.email_categories.collect{|c| Category.find(c,:select => :name).name}.join(", ")
        # else
          # "No email categories selected"
        # end
      # end
      # row "Email streams" do
        # if chalkler.email_streams.present?
          # chalkler.email_streams.collect{|c| Stream.find(c,:select => :name).name}.join(", ")
        # else
          # "No email streams selected"
        # end
      # end
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

  form :partial => 'form'

  action_item(:only => :show, if: proc{ can?(:send_reset_password_mail, resource) && chalkler.email? }) do
    link_to 'Send password reset email', send_reset_password_mail_admin_chalkler_path(resource),
      :data => { :confirm => "Are you sure you want to send password reset instructions?" }
  end

  member_action :send_reset_password_mail do
    chalkler = Chalkler.find params[:id]
    if can?(:send_reset_password_mail, chalkler) && chalkler.send_reset_password_instructions
      flash[:notice] = 'Password reset instructions have been sent!'
    else
      flash[:warn] = 'Could not send password reset instructions!'
    end
    redirect_to :back
  end
end
