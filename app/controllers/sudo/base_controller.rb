class Sudo::BaseController < ApplicationController
  before_filter :authorize_super, :sudo_header
  
  def authorize_super
    authorize :sudo, :super?
  end

  def sudo_header
    @header_partial = '/layouts/headers/sudo'
  end

end
