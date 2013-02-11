Chalkle::Application.routes.draw do
  ActiveAdmin.routes(self)

  devise_for :admin_users, ActiveAdmin::Devise.config
  devise_for :chalklers, :controllers => { :omniauth_callbacks => "chalklers/omniauth_callbacks" }

  root to: "chalklers/dashboard#index"

  namespace :chalklers do
    root to: "dashboard#index"
    match '/classes' => 'dashboard#classes', as: 'classes'
    resources :teachings
    get '/preferences' => 'preferences#show', as: 'preferences'
    put '/preferences' => 'preferences#save', as: 'preferences'
  end

  match '/image' => 'image#generate'
end
