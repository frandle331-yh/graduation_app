Rails.application.routes.draw do
  get "profiles/edit"
  get "profiles/update"
  devise_for :users
  resource :profile, only: [:edit, :update]
  get "home/index"
  # アプリのトップページ
  root "home#index"

  # Railsのヘルスチェック（Rails7〜8のデフォルト）
  get "up" => "rails/health#show", as: :rails_health_check
end
