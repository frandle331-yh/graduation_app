class ProfilesController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user
    @total_logs = @user.housework_logs.count
    @total_minutes = @user.housework_logs.sum(:minutes)
    @streak = @user.current_streak
    @badges = @user.achievement_badges
    @earned_count = @badges.count { |b| b[:earned] }
    @category_breakdown = @user.housework_logs.group(:category).count
    @member_since = @user.created_at

    # 直近90日のヒートマップデータ
    @heatmap = @user.housework_logs
      .where(performed_on: 90.days.ago.to_date..Date.current)
      .group(:performed_on)
      .count
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(profile_params)
      redirect_to edit_profile_path, notice: "プロフィールを更新しました"
    else
      flash.now[:alert] = "入力内容を確認してください"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    user = current_user
    user.update!(withdrawn_at: Time.current)
    sign_out user
    redirect_to root_path, notice: "退会処理が完了しました"
  end

  private

  def profile_params
    params.require(:user).permit(:nickname)
  end
end
