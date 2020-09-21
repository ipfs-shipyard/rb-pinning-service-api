require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => "/sidekiq"

  namespace :api do
    namespace :v1, defaults: {format: :json} do
      post '/users', to: 'users#create'
      delete '/users', to: 'users#destroy'
      resources :pins, except: [:new, :edit] do
        member do
          post :update
        end
      end
    end
  end

  resources :users, only: [:new, :create, :destroy]

  get 'account', to: 'users#show', as: :account
  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  get 'logout', to: 'sessions#destroy'

  resources :pins

  root to: 'pins#index'
end
