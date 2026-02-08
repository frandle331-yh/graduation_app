class DashboardsController < ApplicationController
  before_action :authenticate_user!

  def show
    @household = current_household
    unless @household
      # 世帯がない場合は誘導だけ表示して、家事ログは使える設計
      return
    end

    week_range = Time.zone.today.beginning_of_week..Time.zone.today.end_of_week

    household_scope = HouseworkLog.where(household_id: @household.id)
    user_scope      = household_scope.where(user_id: current_user.id)

    weekly_household = household_scope.where(performed_on: week_range)
    weekly_user      = user_scope.where(performed_on: week_range)

    # ===== 世帯（今週）: 回数 =====
    @weekly_total_count = weekly_household.count
    counts_by_user_id   = weekly_household.group(:user_id).count
    users_by_id         = User.where(id: counts_by_user_id.keys).index_by(&:id)

    @weekly_counts_by_user =
      counts_by_user_id.transform_keys { |uid| users_by_id[uid] }.compact

    @weekly_count_rates_by_user =
      @weekly_counts_by_user.transform_values do |count|
        @weekly_total_count.zero? ? 0 : ((count.to_f / @weekly_total_count) * 100).round(1)
      end

    # ===== 世帯（今週）: 分数 =====
    @weekly_total_minutes = weekly_household.sum(:minutes)
    minutes_by_user_id    = weekly_household.group(:user_id).sum(:minutes)

    @weekly_minutes_by_user =
      minutes_by_user_id.transform_keys { |uid| users_by_id[uid] }.compact

    @weekly_minutes_rates_by_user =
      @weekly_minutes_by_user.transform_values do |minutes|
        @weekly_total_minutes.to_i.zero? ? 0 : ((minutes.to_f / @weekly_total_minutes) * 100).round(1)
      end

    # ===== 個人（今週） =====
    @my_weekly_count   = weekly_user.count
    @my_weekly_minutes = weekly_user.sum(:minutes)

    # ===== 個人（今週）カテゴリ別 =====
    @my_category_counts  = weekly_user.group(:category).count
    @my_category_minutes = weekly_user.group(:category).sum(:minutes)

    # ===== 個人（直近7日） =====
    @my_daily_counts =
      user_scope.group(:performed_on)
                .count
                .sort_by { |date, _| date }
                .last(7)
                .to_h

    @my_daily_minutes =
      user_scope.group(:performed_on)
                .sum(:minutes)
                .sort_by { |date, _| date }
                .last(7)
                .to_h
  end
end
