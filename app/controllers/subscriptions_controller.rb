class SubscriptionsController < ApplicationController
	inherit_resources
	actions :create, :destroy
	belongs_to :provider
	respond_to :js
  before_filter [:load_provider]
  before_filter :authenticate_chalkler!

  before_filter :header_provider

  def index
    @chalklers = @provider.chalklers
  end

  def create
    Subscription.create provider_id: @provider.id, chalkler_id: current_chalkler.id
    add_flash :success, "You are now following "+@provider.name
    redirect_to session[:previous_url] || provider_path(@provider.url_name)
  end

  def destroy
    Subscription.where(provider_id: @provider.id, chalkler_id: current_chalkler.id).destroy_all
    add_flash :warning, "You are no longer following "+@provider.name
    redirect_to session[:previous_url] || provider_path(@provider.url_name) 
  end

  def new
    authorize @provider, :subscribe_follower?
  end

  def new_from_csv
    authorize @provider, :subscribe_follower?

    redirect_to new_provider_subscription_path(@provider), flash: { error: "CSV upload failed, no file attached" } and return unless params[:followers_csv]

    warnings = []
    errors = []
    @followers = []
    @potential_followers = []
    csv = CSV.read params[:followers_csv].path

    csv.each do |row|

      email = row[0]
      chalkler = Chalkler.find_by_email email

      existing_follower = chalkler ? @provider.subscriptions.find_by_chalkler_id(chalkler.id) : @provider.subscriptions.find_by_pseudo_chalkler_email(email)

      unless existing_follower

        new_follower = if chalkler
          Subscription.create chalkler: chalkler, provider: @provider
        else
          Subscription.create pseudo_chalkler_email: email, provider: @provider
        end

        unless new_follower.persisted?
          errors << "Problem occured creating follower with email #{email}" 
        else
          #Notify.for(new_follower).subscribed_to(@provider)
        end

        if new_follower.chalkler?
          @followers << new_follower
        else
          @potential_followers << new_follower
        end

      else
        warnings << "#{email} has already been added as a follower"
      end

    end

    redirect_to provider_subscriptions_path, flash: { success: ["#{@followers.count} new followers", "#{@potential_followers.count} new pending followers" ], errors: warnings } and return
  end


private

	def end_of_association_chain
    super.where(chalkler_id: current_chalkler.id)
  end

  def resource
    @subscription ||= end_of_association_chain.first
  end

  def destroy_resource(object)
    object.destroy if object
  end

end
