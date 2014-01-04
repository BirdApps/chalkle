class Chalklers::BaseController < ApplicationController
  before_filter :authenticate_chalkler!
end
