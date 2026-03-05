class HouseworkLogsController < ApplicationController
  before_action :authenticate_user!

  def index
    @filter = HouseworkLogFilter.new(user: current_user, household: current_household, params: params)

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

    @housework_logs = @filter.scope
      .order(order_clause)
      .page(params[:page])
      .per(10)

    stats = @filter.stats
    @category_summaries  = stats[:category_summaries]
    @daily_summaries     = @filter.daily_summaries
    @stats_total_count   = stats[:total_count]
    @stats_total_minutes = stats[:total_minutes]
    @stats_top_category  = stats[:top_category]

    @templates = current_user.housework_templates.ordered
  end

  def new
    @housework_log = HouseworkLog.new(performed_on: Time.zone.today)
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
    @housework_log = accessible_log(params[:id])
  end

  def thanks
    log = accessible_log(params[:id])
    if log.user_id == current_user.id
      render json: { error: "自分のログには「ありがとう」できません" }, status: :unprocessable_entity
      return
    end
    log.increment!(:thanks_count)
    render json: { thanks_count: log.thanks_count }
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

    authorized =
      if current_household
        source.user_id == current_user.id || source.household_id == current_household.id
      else
        source.user_id == current_user.id
      end

    unless authorized
      redirect_to housework_logs_path, alert: "この家事ログは複製できません"
      return
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

  def suggest_titles
    cat = params[:category].to_s
    if HouseworkLog.categories.key?(cat)
      render json: HouseworkLog.suggest_titles_for(current_user, cat)
    else
      render json: []
    end
  end

  private

  def accessible_log(id)
    HouseworkLog.accessible_by(current_user, current_household).find(id)
  end

  def housework_log_params
    params.require(:housework_log).permit(:title, :category, :performed_on, :minutes, :memo)
  end

  def sanitize_sql_like(str)
    str.gsub(/[\\%_]/) { |c| "\\#{c}" }
  end
end
