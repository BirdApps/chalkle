class Sudo::SilviasController < Sudo::BaseController
  before_filter :authorize_super
  before_filter :set_titles
  def index
  end
end