class SubscriptionsController < ApplicationController
	inherit_resources
	actions :create, :destroy
	belongs_to :provider
	respond_to :js
  before_filter [:load_provider]
  before_filter :authenticate_chalkler!

  before_filter :header_provider
  before_filter :sidebar_administrate_provider

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
