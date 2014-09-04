require 'routing_constraints'
Chalkle::Application.routes.draw do

  ActiveAdmin.routes(self)

  match '(*any)' => redirect { |p, req| req.url.sub!('my.', '') } , :constraints => { :host => /^my\./ }
  match '(*any)' => redirect { |p, req| req.url.sub!('www.', '') } , :constraints => { :host => /^www\./ }

  devise_for :admin_users, ActiveAdmin::Devise.config
  devise_for :chalklers, controllers: { omniauth_callbacks: 'people/omniauth_callbacks', registrations: 'people/registrations' }
  
  constraints(Subdomain) do
    match '/' => 'channels#show'
  end

  root to: 'courses#index'
  
  resources :channel_teachers, path: 'teachers'

  resources :courses, path: 'classes' do
    resources :notices
    resources :bookings do
      member do
        put 'cancel'
      end
    end
    member do
      put 'change_status', to: 'courses#change_status', as: :change_status
    end
  end

  namespace :me do
    root to: 'dashboard#index'
    get '/bookings' => 'dashboard#bookings', as: :bookings
    get '/preferences' => 'preferences#show', as: :preferences
    put '/preferences' => 'preferences#save', as: :preferences
    get '/enter_email' => 'preferences#enter_email', as: :enter_email
    put '/enter_email' => 'preferences#enter_email', as: :enter_email
  end

  resources :chalklers, path: 'people' do
    collection do
      get '/preferences/meetup_email_settings' => 'preferences#meetup_email_settings', as: :meetup_email_settings

      delete '/preferences/destroy_chalkler/:id' => 'preferences#destroy', as: :delete

      get  '/data_collection/:action', as: 'data_collection', controller: :data_collection_form
      post '/data_collection/:action', as: 'data_collection_update', controller: :data_collection_form
    end
  end

  resources :channels, path: 'providers', only: [:index] do
    resources :course_suggestions, only: [:new, :create], path: 'class_suggestions'
    resources :subscriptions, only: [:create, :destroy], path: 'follow'
  end

  get '/styleguide' => 'application#styleguide', as: 'styleguide'
  match '/image' => 'image#generate'

  %w(welcome about blog learn).each do |name|
    match "/#{name}" => redirect("http://blog.chalkle.com/#{name}"), :as => name.to_sym
  end

  get '/partners' => 'partners#index'
  get '/partners/pricing' => 'partners#pricing'
  get '/partners/team' => 'partners#team'
  get '/partners/say_hello' => 'partners#say_hello'
  post '/partners/said_hello', as: 'said_hello', controller: 'partners'

  get 'resources', to: 'resources#index', as: :resources
  get 'metrics', to: 'metrics#index', as: :metrics
  get 'search', to: 'search#index', as: :search

  get 'categories', to: 'categories#index', as: :categories
  get 'categories/:category_url_name', to: 'categories#show', as: :category

  #TODO: find an easier way of doing these channel routes!
  get ':channel_url_name/:course_url_name', to: 'channels#series', as: :channel_course_series
  get '*channel_url_name/*course_url_name/:id', to: 'courses#show', as: :channel_course
  get ':channel_url_name/teachers', to: 'providers#teachers', as: :channel_channel_teachers
  get ':channel_url_name/teacher/:id', to: 'providers#teachers', as: :channel_channel_teacher
  get ':channel_url_name/edit', to: 'channels#edit', as: :channel_edit
  get ':channel_url_name/contact', to: 'channels#contact', as: :channel_contact
  get ':channel_url_name/followers', to: 'channels#followers', as: :channel_followers
  get ':channel_url_name', to: 'channels#show', as: :channel

constraints(MainDomain) do
    get ':country_code/:region_name', to: 'courses#index', constraints: {country_code: /[a-zA-Z]{2}/}
  end

end
