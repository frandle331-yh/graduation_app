require "rails_helper"

RSpec.describe "HouseworkLogs", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  describe "GET /housework_logs" do
    context "未ログインの場合" do
      it "ログインページにリダイレクトする" do
        get housework_logs_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログイン済みの場合" do
      before { sign_in user }

      it "正常にレスポンスを返す" do
        get housework_logs_path
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "GET /housework_logs/new" do
    context "未ログインの場合" do
      it "ログインページにリダイレクトする" do
        get new_housework_log_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログイン済みの場合" do
      before { sign_in user }

      it "正常にレスポンスを返す" do
        get new_housework_log_path
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "POST /housework_logs" do
    context "ログイン済みで有効なパラメータの場合" do
      before { sign_in user }

      it "ログを作成してリダイレクトする" do
        expect {
          post housework_logs_path, params: {
            housework_log: {
              title: "掃除",
              category: "cleaning",
              performed_on: Time.zone.today,
              minutes: 30
            }
          }
        }.to change(HouseworkLog, :count).by(1)
        expect(response).to redirect_to(housework_logs_path)
      end
    end

    context "ログイン済みで無効なパラメータの場合" do
      before { sign_in user }

      it "ログを作成せずにフォームを再表示する" do
        expect {
          post housework_logs_path, params: {
            housework_log: { title: "", category: "cleaning", performed_on: Time.zone.today, minutes: 30 }
          }
        }.not_to change(HouseworkLog, :count)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /housework_logs/:id/edit" do
    context "自分のログの場合" do
      let(:log) { create(:housework_log, user: user) }

      before { sign_in user }

      it "正常にレスポンスを返す" do
        get edit_housework_log_path(log)
        expect(response).to have_http_status(:ok)
      end
    end

    context "他ユーザーのログの場合" do
      let(:log) { create(:housework_log, user: other_user) }

      before { sign_in user }

      it "リダイレクトする" do
        get edit_housework_log_path(log)
        expect(response).to redirect_to(housework_logs_path)
      end
    end
  end

  describe "PATCH /housework_logs/:id" do
    context "自分のログを更新する場合" do
      let(:log) { create(:housework_log, user: user) }

      before { sign_in user }

      it "更新してリダイレクトする" do
        patch housework_log_path(log), params: {
          housework_log: { title: "更新した掃除" }
        }
        expect(response).to redirect_to(housework_logs_path)
        expect(log.reload.title).to eq("更新した掃除")
      end
    end

    context "他ユーザーのログを更新しようとする場合" do
      let(:log) { create(:housework_log, user: other_user) }

      before { sign_in user }

      it "リダイレクトする" do
        patch housework_log_path(log), params: {
          housework_log: { title: "不正な更新" }
        }
        expect(response).to redirect_to(housework_logs_path)
        expect(log.reload.title).not_to eq("不正な更新")
      end
    end
  end

  describe "DELETE /housework_logs/:id" do
    context "自分のログを削除する場合" do
      let!(:log) { create(:housework_log, user: user) }

      before { sign_in user }

      it "削除してリダイレクトする" do
        expect {
          delete housework_log_path(log)
        }.to change(HouseworkLog, :count).by(-1)
        expect(response).to redirect_to(housework_logs_path)
      end
    end

    context "他ユーザーのログを削除しようとする場合" do
      let!(:log) { create(:housework_log, user: other_user) }

      before { sign_in user }

      it "削除されずにリダイレクトする" do
        expect {
          delete housework_log_path(log)
        }.not_to change(HouseworkLog, :count)
        expect(response).to redirect_to(housework_logs_path)
      end
    end
  end
end
