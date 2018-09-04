Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v1 do
      resources :games, only: [:create] do
        post "/shots", to: "games/shots#create"
        post "/ships", to: "games/ships#create"
      end
    end
  end

  get '/confirmation', to: "confirmation#update"
  get '/confirmed', to: "confirmation#show"

  resources :users, only: [:new, :create]

  root to: "welcome#show"
  get "/register", to: "users#new"
  get "/dashboard", to: "dashboard#show"
end
