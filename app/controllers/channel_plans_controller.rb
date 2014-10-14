class ChannelPlansController < ApplicationController
  before_filter :load_channel_plan, except: [:index]
  def index
    @page_subtitle = 'Channel'
    @page_title = 'Plans'
    @channel_plans = ChannelPlan.all
    authorize ChannelPlan.new
  end

  def show
    authorize ChannelPlan.new
    not_found if @channel_plans.nil?
  end

  def edit
    authorize ChannelPlan.new
    not_found if @channel_plans.nil?
  end

  private
    def load_channel_plan
      @channel_plan = ChannelPlan.find params[:id]
    end
end