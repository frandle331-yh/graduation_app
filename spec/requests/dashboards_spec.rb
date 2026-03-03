require "rails_helper"

RSpec.describe "Dashboards", type: :request do
  describe "GET /dashboard" do
    context "未ログインの場合" do
      it "ログインページにリダイレクトする" do
        get dashboard_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログイン済みの場合" do
      let(:user) { create(:user) }

      before { sign_in user }

      it "正常にレスポンスを返す" do
        get dashboard_path
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
