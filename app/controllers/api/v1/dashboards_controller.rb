# frozen_string_literal: true

module Api
  module V1
    class DashboardsController < BaseController
      def show
        presenter = DashboardPresenter.new(
          user: current_user,
          household: current_household,
          period: params[:period]
        )

        render json: {
          period: presenter.period,
          period_label: presenter.period_label,
          streak: presenter.streak,
          weekly_log_days: presenter.weekly_log_days,
          total_minutes: presenter.total_minutes,
          total_count: presenter.total_count,
          category_summaries: presenter.category_summaries,
          weekly_summary: presenter.weekly_summary,
          earned_badge_count: presenter.earned_badge_count,
          total_badge_count: presenter.badges.size
        }
      end
    end
  end
end
