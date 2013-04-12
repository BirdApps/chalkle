Chalkle::Application.routes.draw do
  ActiveAdmin.routes(self)

  devise_for :admin_users, ActiveAdmin::Devise.config
  devise_for :chalklers, :controllers => { :omniauth_callbacks => "chalklers/omniauth_callbacks" }

  root to: "chalklers/dashboard#index"

  namespace :chalklers do
    root to: "dashboard#index"
    match '/classes' => 'dashboard#classes', as: 'classes'
    get '/enter_email' => 'preferences#enter_email', as: 'enter_email'
    put '/enter_email' => 'preferences#enter_email', as: 'enter_email'
    resources :teachings do
      collection do
        get 'success'
      end
    end
    get '/preferences' => 'preferences#show', as: 'preferences'
    get '/preferences/meetup_email_settings' => 'preferences#meetup_email_settings', as: 'meetup_email_settings'
    put '/preferences' => 'preferences#save', as: 'preferences'
  end

  match '/image' => 'image#generate'
end
