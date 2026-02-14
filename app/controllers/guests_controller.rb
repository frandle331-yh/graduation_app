class GuestsController < ApplicationController
  def create
    # 毎回ユニークなゲストユーザーを作成（採用担当者ごとに独立したデータで体験できる）
    guest = User.create!(
      email:    "guest_#{SecureRandom.hex(8)}@kajilog.example.com",
      password: SecureRandom.hex(16),
      nickname: "ゲスト"
    )
    sign_in guest
    redirect_to dashboard_path, notice: "ゲストとしてログインしました。自由にお試しください 🏠"
  end
end
