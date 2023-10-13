Rails.application.routes.draw do
  # get 'uploads/new'
  #get 'uploads/create'
  resources :uploads, only: [:new, :create]
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  namespace :api do
    namespace :v1 do
      resources :searches, only: [:index]
    end
  get "up" => "rails/health#show", as: :rails_health_check
  get 'applicants/savedata'
  namespace 'api' do
    namespace 'v1' do
      resources :applicantsapi
    end
  end
  # Defines the root path route ("/")

  #routes for file upload
  # post 'uploads', to: 'uploads#new'




  # root "posts#index"

end

end
