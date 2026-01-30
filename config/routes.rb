Rails.application.routes.draw do
  devise_for :users
  get "home/index"
  # アプリのトップページ
  root "home#index"

  # Railsのヘルスチェック（Rails7〜8のデフォルト）
  get "up" => "rails/health#show", as: :rails_health_check
end
