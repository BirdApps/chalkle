module ControllerMacros
  def login_chalkler
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      user = FactoryGirl.create(:chalkler)
      sign_in user
    end
  end

end
