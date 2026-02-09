class DashboardsController < ApplicationController
  before_action :authenticate_user!

  def show
    @household = current_household

    base_scope =
      if @household
        HouseworkLog.where(household_id: @household.id)
      else
        current_user.housework_logs
      end

    week_range = Time.zone.today.beginning_of_week..Time.zone.today.end_of_week
    weekly_scope = base_scope.where(performed_on: week_range)

    # ===== 共通（今週）: 分数 =====
    @weekly_total_minutes = weekly_scope.sum(:minutes)
    @category_summaries   = weekly_scope.group(:category).sum(:minutes)

    @daily_summaries =
      weekly_scope
        .group(:performed_on)
        .sum(:minutes)
        .sort_by { |date, _| date }
        .last(7)
        .to_h

    # ===== 世帯のみ（今週）: ユーザー別 分数 + 比率 =====
    if @household
      minutes_by_user_id = weekly_scope.group(:user_id).sum(:minutes)

      users_by_id = User.where(id: minutes_by_user_id.keys).index_by(&:id)

      @weekly_minutes_by_user =
        minutes_by_user_id.transform_keys { |uid| users_by_id[uid] }.compact

      total = @weekly_total_minutes.to_i
      @weekly_minutes_rates_by_user =
        @weekly_minutes_by_user.transform_values do |minutes|
          total.zero? ? 0 : ((minutes.to_f / total) * 100).round(1)
        end
    end
  end
end
