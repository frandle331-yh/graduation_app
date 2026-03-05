class GuestsController < ApplicationController
  def create
    # ゲスト作成時に古いゲストの定期クリーンアップをバックグラウンドで実行
    GuestCleanupJob.perform_later

    guest = User.create!(
      email:    "guest_#{SecureRandom.hex(8)}@kajimate.example.com",
      password: SecureRandom.hex(16),
      nickname: "ゲスト"
    )
    sign_in guest
    redirect_to dashboard_path, notice: "ゲストとしてログインしました。自由にお試しください 🏠"
  end
end
