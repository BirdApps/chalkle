class Chalklers::BaseController < ApplicationController
  layout 'chalklers' 

  before_filter :authenticate_chalkler!
end
