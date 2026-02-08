class HouseworkLogsController < ApplicationController
  before_action :authenticate_user!

  def index
    base_scope = filtered_scope

    @sort = params[:sort].presence || "performed_desc"

    order_clause =
      case @sort
      when "created_desc"
        { created_at: :desc }
      when "performed_asc"
        { performed_on: :asc, created_at: :asc }
      else # "performed_desc"
        { performed_on: :desc, created_at: :desc }
      end

    @housework_logs = base_scope
      .order(order_clause)
      .page(params[:page])
      .per(10)

    @category_summaries = base_scope.group(:category).sum(:minutes)
    @daily_summaries    = build_daily_summaries(base_scope)
  end



  def new
    @housework_log = HouseworkLog.new
  end

  def create
    @housework_log = current_user.housework_logs.build(housework_log_params)
    if @housework_log.save
      redirect_to housework_logs_path, notice: "家事ログを登録しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @housework_log = current_user.housework_logs.find(params[:id])
  end

  def edit
    @housework_log = current_user.housework_logs.find(params[:id])
  end

  def update
    @housework_log = current_user.housework_logs.find(params[:id])
    if @housework_log.update(housework_log_params)
      redirect_to housework_log_path(@housework_log), notice: "家事ログを更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    housework_log = current_user.housework_logs.find(params[:id])
    housework_log.destroy
    redirect_to housework_logs_path, notice: "家事ログを削除しました"
  end

  private

  def housework_log_params
    params.require(:housework_log).permit(:title, :category, :performed_on, :minutes, :memo)
  end

  def filtered_scope
    scope = current_user.housework_logs
    scope = apply_period(scope)
    scope = apply_category(scope)
    scope
  end

  def apply_period(scope)
    @period = params[:period].presence || "all"
    today = Time.zone.today

    case @period
    when "week"
      scope.where(performed_on: today.beginning_of_week..today.end_of_week)
    when "month"
      scope.where(performed_on: today.beginning_of_month..today.end_of_month)
    else
      @period = "all"
      scope
    end
  end

  def apply_category(scope)
    if params[:category].present? && HouseworkLog.categories.key?(params[:category])
      @selected_category = params[:category]
      scope.where(category: HouseworkLog.categories[@selected_category])
    else
      @selected_category = ""
      scope
    end
  end

  def build_daily_summaries(scope)
    daily_hash   = scope.group(:performed_on).sum(:minutes)
    daily_sorted = daily_hash.sort_by { |date, _| date }.reverse

    @daily_mode = params[:daily].presence || "top7"
    if @daily_mode == "all"
      daily_sorted.to_h
    else
      daily_sorted.first(7).to_h
    end
  end

end
