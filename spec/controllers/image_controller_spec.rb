require 'spec_helper'

describe ImageController do

  describe "GET 'generate'" do
    it "returns http success" do
      get 'generate'
      response.should be_success
    end
  end

end
