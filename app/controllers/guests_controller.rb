class GuestsController < ApplicationController
  def create
    # 古いゲストユーザーを定期的にソフトデリート（7日以上前のゲスト）
    User.where("email LIKE ?", "guest_%@kajilog.example.com")
        .where("created_at < ?", 7.days.ago)
        .where(withdrawn_at: nil)
        .update_all(withdrawn_at: Time.current)

    guest = User.create!(
      email:    "guest_#{SecureRandom.hex(8)}@kajilog.example.com",
      password: SecureRandom.hex(16),
      nickname: "ゲスト"
    )
    sign_in guest
    redirect_to dashboard_path, notice: "ゲストとしてログインしました。自由にお試しください 🏠"
  end
end
