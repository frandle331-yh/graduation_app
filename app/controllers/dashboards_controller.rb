class DashboardsController < ApplicationController
  before_action :authenticate_user!

  PERIOD_LABELS = { "week" => "今週", "month" => "今月", "all" => "全期間" }.freeze

  def show
    @household = current_household
    @period = params[:period].presence_in(%w[week month all]) || "week"

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
    @total_minutes     = period_scope.sum(:minutes)
    @total_count       = period_scope.count
    @category_summaries = period_scope.group(:category).sum(:minutes)

    @daily_summaries =
      period_scope
        .group(:performed_on)
        .sum(:minutes)
        .sort_by { |date, _| date }
        .to_h

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
end
