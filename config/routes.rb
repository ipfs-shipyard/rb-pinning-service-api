require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => "/sidekiq"

  namespace :api do
    namespace :v1 do
      resources :pins, except: [:new, :edit], defaults: {format: :json} do
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
