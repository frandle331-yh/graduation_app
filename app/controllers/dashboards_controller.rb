class DashboardsController < ApplicationController
  before_action :authenticate_user!

  def show
    @household = current_household
    @presenter = DashboardPresenter.new(
      user: current_user,
      household: @household,
      period: params[:period]
    )

    @quick_templates = current_user.housework_templates.ordered.limit(5)
    @recent_logs = current_user.housework_logs
                               .order(performed_on: :desc, created_at: :desc)
                               .limit(5)
  end
end
