require "spec_helper"

describe Sudo::ChalklersController do
  
  login_super
  let!(:chalkler) {FactoryGirl.create(:chalkler)}

  describe "index" do  
    
    it 'renders a list of chalklers' do 
      get :index 
      expect(response).to render_template(:index)
    end

    it 'renders a list of chalklers' do 
      get :index 
      expect(assigns(:chalklers)).to include(chalkler)
    end
  end

  describe "become" do
    it 'redirects to root' do
      post :become, id: chalkler.id
      expect(response).to redirect_to(:root)
    end
  end

  describe "notifications" do
    #TODO
  end

end