class SubscriptionsController < ApplicationController
	inherit_resources
	actions :create, :destroy
	belongs_to :channel
	respond_to :js

private

	def end_of_association_chain
    super.where(chalkler_id: current_chalkler.id)
  end

  def resource
    @subscription ||= end_of_association_chain.first
  end
end
