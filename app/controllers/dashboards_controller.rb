class DashboardsController < ApplicationController
  before_action :authenticate_user!

  PERIOD_LABELS = { "week" => "今週", "month" => "今月", "all" => "全期間" }.freeze

  def show
    @household = current_household
    @period = params[:period].presence_in(%w[week month all]) || "week"
    @quick_templates = current_user.housework_templates.ordered.limit(5)
    @recent_logs = current_user.housework_logs
                               .order(performed_on: :desc, created_at: :desc)
                               .limit(5)

    base_scope =
      if @household
        HouseworkLog.where(household_id: @household.id)
      else
        current_user.housework_logs
      end

    today = Time.zone.today
    period_scope = case @period
    when "month"
                     base_scope.where(performed_on: today.beginning_of_month..today.end_of_month)
    when "all"
                     base_scope
    else
                     base_scope.where(performed_on: today.beginning_of_week..today.end_of_week)
    end

    @period_label      = PERIOD_LABELS[@period]
    @streak            = current_user.current_streak
    @weekly_log_days   = current_user.weekly_log_days
    @total_minutes     = period_scope.sum(:minutes)
    @total_count       = period_scope.count
    @category_summaries = period_scope.group(:category).sum(:minutes)

    @daily_summaries =
      period_scope
        .group(:performed_on)
        .sum(:minutes)
        .sort_by { |date, _| date }
        .to_h

    # 週次サマリー（常に表示）
    build_weekly_summary(base_scope, today)

    # 達成バッジ
    @badges = current_user.achievement_badges
    @earned_count = @badges.count { |b| b[:earned] }

    # カレンダー（今月）
    build_calendar(current_user, today)

    return unless @household

    minutes_by_user_id = period_scope.group(:user_id).sum(:minutes)
    users_by_id = User.where(id: minutes_by_user_id.keys).index_by(&:id)

    @minutes_by_user =
      minutes_by_user_id.transform_keys { |uid| users_by_id[uid] }.compact

    total = @total_minutes.to_i
    @rates_by_user = @minutes_by_user.transform_values do |minutes|
      total.zero? ? 0 : ((minutes.to_f / total) * 100).round(1)
    end
  end

  private

  def build_weekly_summary(base_scope, today)
    this_week = today.beginning_of_week..today.end_of_week
    last_week = (today.beginning_of_week - 7)..(today.end_of_week - 7)

    this_scope = base_scope.where(performed_on: this_week)
    last_scope = base_scope.where(performed_on: last_week)

    @weekly = {
      count: this_scope.count,
      minutes: this_scope.sum(:minutes),
      last_count: last_scope.count,
      last_minutes: last_scope.sum(:minutes),
      top_category: this_scope.group(:category).count.max_by { |_, v| v }&.first,
      avg_minutes_per_day: weekly_avg(this_scope, today)
    }
  end

  def weekly_avg(scope, today)
    days_elapsed = [ (today - today.beginning_of_week).to_i + 1, 1 ].max
    total = scope.sum(:minutes)
    (total.to_f / days_elapsed).round(0)
  end

  def build_calendar(user, today)
    first = today.beginning_of_month
    last  = today.end_of_month
    @cal_month_label = today.strftime("%Y年%-m月")
    @cal_first = first
    @cal_last  = last
    @cal_today = today
    @cal_data  = user.housework_logs
      .where(performed_on: first..last)
      .group(:performed_on)
      .count
  end
end
