class HouseworkLogsController < ApplicationController
  before_action :authenticate_user!

  def index
    base_scope = current_user.housework_logs

    if params[:category].present? && HouseworkLog.categories.key?(params[:category])
      base_scope = base_scope.where(category: HouseworkLog.categories[params[:category]])
      @selected_category = params[:category]
    else
      @selected_category = ""
    end

    @housework_logs = base_scope.order(performed_on: :desc, created_at: :desc)
    @category_summaries = base_scope.group(:category).sum(:minutes)
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
end
