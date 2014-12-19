class Sudo::BaseController < ApplicationController
  before_filter :authorize_super

  
  def authorize_super
    @sudo = Sudo.new
    authorize @sudo
  end

end
