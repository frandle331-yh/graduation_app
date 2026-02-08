class DashboardsController < ApplicationController
  before_action :authenticate_user!

  def show
    scope = current_user.housework_logs

    # 今週
    week_range = Time.zone.today.beginning_of_week..Time.zone.today.end_of_week
    @weekly_total_minutes = scope.where(performed_on: week_range).sum(:minutes)

    # カテゴリ別
    @category_summaries = scope.where(performed_on: week_range)
                               .group(:category)
                               .sum(:minutes)

    # 直近7日
    @daily_summaries =
      scope.group(:performed_on)
           .sum(:minutes)
           .sort_by { |date, _| date }
           .last(7)
           .to_h
  end
end
