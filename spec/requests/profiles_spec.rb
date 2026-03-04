require "rails_helper"

RSpec.describe "Profiles", type: :request do
  let(:user) { create(:user) }

  describe "GET /profile" do
    context "未ログインの場合" do
      it "ログインページにリダイレクトする" do
        get profile_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログイン済みの場合" do
      before { sign_in user }

      it "正常にレスポンスを返す" do
        get profile_path
        expect(response).to have_http_status(:ok)
      end

      it "統計とバッジを表示する" do
        create(:housework_log, user: user, performed_on: Time.zone.today)
        get profile_path
        expect(response.body).to include("累計記録数")
        expect(response.body).to include("達成バッジ")
        expect(response.body).to include("活動ヒートマップ")
      end
    end
  end

  describe "GET /profile/edit" do
    context "未ログインの場合" do
      it "ログインページにリダイレクトする" do
        get edit_profile_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログイン済みの場合" do
      before { sign_in user }

      it "正常にレスポンスを返す" do
        get edit_profile_path
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "PATCH /profile" do
    context "ログイン済みで有効なパラメータの場合" do
      before { sign_in user }

      it "プロフィールを更新してリダイレクトする" do
        patch profile_path, params: { user: { nickname: "新しいニックネーム" } }
        expect(response).to redirect_to(edit_profile_path)
        expect(user.reload.nickname).to eq("新しいニックネーム")
      end
    end

    context "ログイン済みで無効なパラメータの場合" do
      before { sign_in user }

      it "更新せずにフォームを再表示する" do
        patch profile_path, params: { user: { nickname: "" } }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(user.reload.nickname).not_to eq("")
      end
    end
  end

  describe "DELETE /profile" do
    context "ログイン済みの場合" do
      before { sign_in user }

      it "退会処理してルートにリダイレクトする" do
        delete profile_path
        expect(response).to redirect_to(root_path)
        expect(user.reload.withdrawn_at).not_to be_nil
      end
    end

    context "未ログインの場合" do
      it "ログインページにリダイレクトする" do
        delete profile_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
