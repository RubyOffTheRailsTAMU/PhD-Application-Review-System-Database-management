Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.

  get 'welcome/index'
  get 'applicants/savedata'
  root 'welcome#index'
  resources :uploads, only: [:new, :create]

  #Login Logic:
  post '/login', to: 'welcome#create'
  get '/logout', to: 'welcome#destroy'

  #Logic to clear database:
  get '/clear_database', to: 'database_clearing#clear'
  #Handle database uploads:
  get '/applicants/uploads_handler', to: 'applicants#uploads_handler'

  namespace :api do
    namespace :v1 do
      resources :searches, only: [:index]
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check

  namespace 'api' do
    namespace 'v1' do
      resources :applicantsapi
    end
  end
end
