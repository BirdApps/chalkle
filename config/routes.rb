Chalkle::Application.routes.draw do
  ActiveAdmin.routes(self)

  devise_for :admin_users, ActiveAdmin::Devise.config
  devise_for :chalklers, :controllers => { :omniauth_callbacks => "chalklers/omniauth_callbacks" }

  root to: "chalklers/dashboard#index"

  match "channels/horowhenua" => "channels#horowhenua"

  resources :channels do
    resources :lessons
  end

  namespace :chalklers do
    root to: "dashboard#index"
    resources :lesson_suggestions, :only => [:new, :create]

    get '/enter_email' => 'preferences#enter_email', as: 'enter_email'
    put '/enter_email' => 'preferences#enter_email', as: 'enter_email'

    match '/missing_channel' => 'dashboard#missing_channel'

    resources :teachings do
      collection do
        get 'success'
      end
    end

    get '/preferences' => 'preferences#show', as: 'preferences'
    get '/preferences/meetup_email_settings' => 'preferences#meetup_email_settings', as: 'meetup_email_settings'
    put '/preferences' => 'preferences#save', as: 'preferences'
  end

  get '/styleguide' => 'application#styleguide', as: 'styleguide'
  match '/image' => 'image#generate'
end
