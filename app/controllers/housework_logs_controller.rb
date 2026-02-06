class HouseworkLogsController < ApplicationController
  before_action :authenticate_user!

  def index
    @housework_logs = current_user.housework_logs.order(performed_on: :desc)
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

  private

  def housework_log_params
    params.require(:housework_log).permit(:title, :category, :performed_on, :minutes, :memo)
  end
end
