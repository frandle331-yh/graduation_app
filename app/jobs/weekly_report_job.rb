# frozen_string_literal: true

# 全アクティブユーザーに週次レポートメールを送信する定期ジョブ
class WeeklyReportJob < ApplicationJob
  queue_as :default

  def perform
    users = User.active
                .where.not("email LIKE ?", "guest_%@kajimate.example.com")

    sent_count = 0
    users.find_each do |user|
      WeeklyReportMailer.weekly_report(user).deliver_later
      sent_count += 1
    end

    Rails.logger.info("[WeeklyReportJob] #{sent_count}件の週次レポートを送信キューに追加しました")
  end
end
