module ControllerMacros
  def login_chalkler
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @current_chalkler = FactoryGirl.create(:chalkler)
      sign_in @current_chalkler
    end
  end

  def login_super
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @current_chalkler = FactoryGirl.create(:super_chalkler)
      sign_in @current_chalkler
    end
  end


end
