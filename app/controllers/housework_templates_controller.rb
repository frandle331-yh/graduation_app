class HouseworkTemplatesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_template, only: [:edit, :update, :destroy]

  def index
    @templates = current_user.housework_templates.ordered
  end

  def new
    @template = current_user.housework_templates.build
  end

  def create
    @template = current_user.housework_templates.build(template_params)
    @template.position = current_user.housework_templates.count  # 末尾に追加

    if @template.save
      redirect_to housework_templates_path, notice: "テンプレートを作成しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @template.update(template_params)
      redirect_to housework_templates_path, notice: "テンプレートを更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @template.destroy
    redirect_to housework_templates_path, notice: "テンプレートを削除しました"
  end

  # テンプレートから家事ログを1件作成（ワンタップ記録）
  def use
    template = current_user.housework_templates.find(params[:id])
    log = template.to_log(user: current_user, household: current_household)

    if log.save
      redirect_to housework_logs_path, notice: "「#{template.title}」を記録しました ✓"
    else
      redirect_to housework_logs_path, alert: "記録に失敗しました"
    end
  end

  private

  def set_template
    @template = current_user.housework_templates.find(params[:id])
  end

  def template_params
    params.require(:housework_template).permit(:title, :category, :minutes)
  end
end
