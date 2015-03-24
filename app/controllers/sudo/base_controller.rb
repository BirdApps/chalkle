class Sudo::BaseController < ApplicationController
  before_filter :authorize_super
  
  def authorize_super
    authorize :sudo, :super?
  end

end
