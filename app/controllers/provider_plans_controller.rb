class ProviderPlansController < ApplicationController
  before_filter :load_provider_plan, except: [:index]
  def index
    @page_title = 'Plans'
    @provider_plans = ProviderPlan.all
    authorize ProviderPlan.new
  end

  def show
    authorize ProviderPlan.new
    not_found if @provider_plans.nil?
  end

  def edit
    authorize ProviderPlan.new
    not_found if @provider_plans.nil?
  end

  private
    def load_provider_plan
      @provider_plan = ProviderPlan.find params[:id]
    end
end