require 'spec_helper'

describe Chalklers::DashboardController do
  login_chalkler
  describe "GET 'index'" do
    pending "returns http success" do
      get 'index'
      response.should be_success
    end
  end

end
