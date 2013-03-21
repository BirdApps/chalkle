Chalkle::Application.routes.draw do
  ActiveAdmin.routes(self)

  devise_for :admin_users, ActiveAdmin::Devise.config
  devise_for :chalklers, :controllers => { :omniauth_callbacks => "chalklers/omniauth_callbacks" }

  root to: "chalklers/dashboard#index"

  namespace :chalklers do
    root to: "dashboard#index"
    match '/classes' => 'dashboard#classes', as: 'classes'
    match '/email_update' => 'preferences#update_email', as: 'update_email'
    resources :teachings do
      collection do
        get 'success'
      end
    end
    get '/preferences' => 'preferences#show', as: 'preferences'
    put '/preferences' => 'preferences#save', as: 'preferences'
  end

  match '/image' => 'image#generate'
end
