# frozen_string_literal: true

# 週次レポートメールを送信する
class WeeklyReportMailer < ApplicationMailer
  def weekly_report(user)
    @user = user
    @week_range = 1.week.ago.to_date..Date.current
    logs = user.housework_logs.where(performed_on: @week_range)

    @total_count   = logs.count
    @total_minutes = logs.sum(:minutes)
    @top_category  = logs.group(:category).count.max_by { |_, v| v }&.first
    @streak        = StreakCalculator.new(user).current_streak

    mail(
      to: user.email,
      subject: "#{user.nickname}さんの今週の家事レポート - KajiMate"
    )
  end
end
