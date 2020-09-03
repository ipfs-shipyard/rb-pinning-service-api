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

  resources :pins

  root to: 'pins#index'
end
