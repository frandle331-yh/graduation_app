Rails.application.routes.draw do
  devise_for :users, controllers: {
    omniauth_callbacks: "users/omniauth_callbacks"
  }
  resource :profile, only: [ :show, :edit, :update, :destroy ]
  resources :housework_templates, only: [ :index, :new, :create, :edit, :update, :destroy ] do
    post :use, on: :member
  end
  resources :housework_logs, only: [ :index, :new, :create, :show, :edit, :update, :destroy ] do
    post :quick_create,    on: :collection
    get  :search_titles,   on: :collection
    get  :suggest_titles,  on: :collection
    post :thanks,          on: :member
  end
  resource :dashboard, only: [ :show ]
  resource :household, only: [ :new, :create, :show ] do
    get  :join,  on: :collection
    post :join,  on: :collection
    get  :timeline, on: :member
  end

  get "home/index"
  # 静的ページ（未ログインでもアクセス可）
  get "terms",          to: "pages#terms",          as: :terms
  get "privacy_policy", to: "pages#privacy_policy", as: :privacy_policy
  get "how_to_use",     to: "pages#how_to_use",     as: :how_to_use
  # ゲストログイン
  post "guest_sign_in", to: "guests#create"

  # アプリのトップページ
  root "home#index"

  # API
  namespace :api do
    namespace :v1 do
      resources :housework_logs, only: [ :index, :show, :create ]
      resource :dashboard, only: [ :show ]
    end
  end

  # Railsのヘルスチェック（Rails7〜8のデフォルト）
  get "up" => "rails/health#show", as: :rails_health_check
end
