# frozen_string_literal: true

# 7日以上前に作成されたゲストユーザーをソフトデリートする定期ジョブ
class GuestCleanupJob < ApplicationJob
  queue_as :default

  def perform
    expired_guests = User.where("email LIKE ?", "guest_%@kajimate.example.com")
                         .where("created_at < ?", 7.days.ago)
                         .where(withdrawn_at: nil)

    count = expired_guests.count
    expired_guests.update_all(withdrawn_at: Time.current)

    Rails.logger.info("[GuestCleanupJob] #{count}件のゲストユーザーをソフトデリートしました")
  end
end
