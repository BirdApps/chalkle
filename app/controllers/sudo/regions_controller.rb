class Sudo::RegionsController < Sudo::BaseController
  before_filter :authorize_super
  before_filter :set_titles
  before_filter :set_title

  def index
    @regions = Region.all
  end

  def show
    @region = Region.find(params[:id])
    @page_title = @region.name
  end

  def create
  end

  def edit
  end

  def update
  end


  protected

  def set_title
    @page_title = "Region"
  end

end