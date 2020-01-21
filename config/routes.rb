Rails.application.routes.draw do
  root 'ideas#index'
  
  resources :ideas
  
  resources :ideas do
    resources :reviews, only: [:create, :edit, :update, :destroy]
    resources :likes, shallow: true, only: [:create, :destroy]
  end
  
  resources :users, only: [:create, :new, :edit, :update]
  
  resource :session, only: [:new, :create, :destroy]
  
  resources :reviews, only: [:create, :edit, :update, :destroy]
  
end
