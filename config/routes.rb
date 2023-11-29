Rails.application.routes.draw do
  get "fields/index"
  get "fields/show"
  get "fields/new"
  get "fields/edit"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.

  get "welcome/index"
  root "welcome#index"
  resources :uploads, only: [:new, :create]
  get "applicants/savedata"
  get "applicants/process_input"
  get "applicants/uploads_handler"
  post '/applicants/uploads_handler', to: 'applicants#uploads_handler_post'

  #Login Logic:
  post "/login", to: "welcome#create"
  get "/logout", to: "welcome#destroy"
  resources :fields

  #Logic to clear database:
  get "/clear_database", to: "database_clearing#clear"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  namespace :api do
    namespace :v1 do
      resources :searches, only: [:index]
      get "field_names", to: "searches#field_names"
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check

  namespace "api" do
    namespace "v1" do
      resources :applicantsapi
    end
  end
end