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

      it "404を返す" do
        get edit_housework_log_path(log)
        expect(response).to have_http_status(:not_found)
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
        expect(response).to redirect_to(housework_log_path(log))
        expect(log.reload.title).to eq("更新した掃除")
      end
    end

    context "他ユーザーのログを更新しようとする場合" do
      let(:log) { create(:housework_log, user: other_user) }

      before { sign_in user }

      it "404を返し更新されない" do
        patch housework_log_path(log), params: {
          housework_log: { title: "不正な更新" }
        }
        expect(response).to have_http_status(:not_found)
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

      it "削除されずに404を返す" do
        expect {
          delete housework_log_path(log)
        }.not_to change(HouseworkLog, :count)
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "POST /housework_logs/quick_create" do
    context "自分のログを複製する場合" do
      let!(:log) { create(:housework_log, user: user) }

      before { sign_in user }

      it "新しいログを1件作成してリダイレクトする" do
        expect {
          post quick_create_housework_logs_path, params: { source_id: log.id }
        }.to change(HouseworkLog, :count).by(1)
        expect(response).to redirect_to(housework_logs_path)
      end

      it "作成されたログの日付は今日になる" do
        post quick_create_housework_logs_path, params: { source_id: log.id }
        expect(HouseworkLog.last.performed_on).to eq(Time.zone.today)
      end
    end

    context "他ユーザーのログ（世帯なし）を複製しようとする場合" do
      let!(:other_log) { create(:housework_log, user: other_user) }

      before { sign_in user }

      it "作成せずにリダイレクトしアラートを表示する" do
        expect {
          post quick_create_housework_logs_path, params: { source_id: other_log.id }
        }.not_to change(HouseworkLog, :count)
        expect(response).to redirect_to(housework_logs_path)
      end
    end
  end

  describe "GET /housework_logs/search_titles" do
    before do
      sign_in user
      create(:housework_log, user: user, title: "掃除機かけ")
      create(:housework_log, user: user, title: "風呂掃除")
      create(:housework_log, user: other_user, title: "他ユーザーの掃除")
    end

    it "自分のログのタイトルのみをJSONで返す" do
      get search_titles_housework_logs_path, params: { q: "掃除" }
      expect(response).to have_http_status(:ok)
      titles = JSON.parse(response.body)
      expect(titles).to include("掃除機かけ", "風呂掃除")
      expect(titles).not_to include("他ユーザーの掃除")
    end

    it "クエリが空の場合は空配列を返す" do
      get search_titles_housework_logs_path, params: { q: "" }
      expect(JSON.parse(response.body)).to eq([])
    end
  end
end
