module IntegrationSpecHelper
  def login_with_oauth(service = :meetup)
    visit "/auth/#{service}"
  end
end