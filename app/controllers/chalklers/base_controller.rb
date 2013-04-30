class Chalklers::BaseController < ApplicationController
  before_filter :authenticate_chalkler!
  before_filter :has_channel_membership?, :except => [ :login, :missing_channel ]

  protected

  def has_channel_membership?
    if current_chalkler.channels.empty?
      redirect_to chalklers_missing_channel_path
    end
  end
end
