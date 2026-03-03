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
    @housework_log.household = current_household
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

  def quick_create
    source = HouseworkLog.find(params.require(:source_id))

    # 自分のログ or 同じ世帯のログのみ複製可
    if current_household
      unless source.household_id == current_household.id
        redirect_to housework_logs_path, alert: "この家事ログは複製できません"
        return
      end
    else
      unless source.user_id == current_user.id
        redirect_to housework_logs_path, alert: "この家事ログは複製できません"
        return
      end
    end

    new_log = HouseworkLog.new(
      title: source.title,
      category: source.category,
      minutes: source.minutes,
      memo: source.memo,
      performed_on: Time.zone.today,
      user: current_user,
      household: current_household
    )

    new_log.save!
    redirect_to housework_logs_path, notice: "ワンタップで家事を記録しました"
  rescue ActiveRecord::RecordNotFound
    redirect_to housework_logs_path, alert: "元の家事ログが見つかりません"
  rescue ActiveRecord::RecordInvalid => e
    redirect_to housework_logs_path, alert: e.record.errors.full_messages.to_sentence
  end


  private

  def housework_log_params
    params.require(:housework_log).permit(:title, :category, :performed_on, :minutes, :memo)
  end

  # オートコンプリート用：タイトルのサジェストを JSON で返す
  def search_titles
    q = params[:q].to_s.strip
    titles =
      if q.present?
        current_user.housework_logs
                    .where("title ILIKE ?", "%#{sanitize_sql_like(q)}%")
                    .distinct
                    .order(:title)
                    .limit(8)
                    .pluck(:title)
      else
        []
      end
    render json: titles
  end

  def filtered_scope
    scope = current_user.housework_logs
    scope = apply_period(scope)
    scope = apply_category(scope)
    scope = apply_keyword(scope)
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

  def apply_keyword(scope)
    @keyword = params[:keyword].to_s.strip
    if @keyword.present?
      scope.where("title ILIKE ?", "%#{sanitize_sql_like(@keyword)}%")
    else
      scope
    end
  end

  def sanitize_sql_like(str)
    str.gsub(/[\\%_]/) { |c| "\\#{c}" }
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
