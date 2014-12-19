require "spec_helper"

describe Sudo::BookingsController do
  
  login_super
  let!(:chalkler) {FactoryGirl.create(:chalkler)}

  describe "index" do  
    
    it 'renders a list of chalklers' do 
      get :index 
      expect(response).to render_template(:index)
    end

  end

end