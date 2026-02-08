class ProfilesController < ApplicationController
  before_action :authenticate_user!

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
