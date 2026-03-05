require "rails_helper"

RSpec.describe "Api::V1::HouseworkLogs", type: :request do
  let(:user) { create(:user) }
  let(:token) { user.generate_api_token! }
  let(:headers) { { "Authorization" => "Bearer #{token}", "Content-Type" => "application/json" } }

  describe "GET /api/v1/housework_logs" do
    context "認証なし" do
      it "401を返す" do
        get api_v1_housework_logs_path
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "認証あり" do
      before do
        create(:housework_log, user: user, title: "掃除", category: :cleaning, performed_on: Date.current)
        create(:housework_log, user: user, title: "料理", category: :cooking, performed_on: Date.current)
      end

      it "家事ログ一覧を返す" do
        get api_v1_housework_logs_path, headers: headers
        expect(response).to have_http_status(:ok)

        json = response.parsed_body
        expect(json.size).to eq(2)
        expect(json.first).to include("title", "category", "minutes")
      end

      it "カテゴリでフィルタできる" do
        get api_v1_housework_logs_path, params: { category: "cleaning" }, headers: headers
        json = response.parsed_body
        expect(json.size).to eq(1)
        expect(json.first["category"]).to eq("cleaning")
      end
    end
  end

  describe "GET /api/v1/housework_logs/:id" do
    let!(:log) { create(:housework_log, user: user, title: "掃除機") }

    it "個別の家事ログを返す" do
      get api_v1_housework_log_path(log), headers: headers
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["title"]).to eq("掃除機")
    end
  end

  describe "POST /api/v1/housework_logs" do
    let(:valid_params) do
      { housework_log: { category: "cleaning", performed_on: Date.current.to_s, minutes: 30 } }
    end

    it "家事ログを作成できる" do
      expect {
        post api_v1_housework_logs_path, params: valid_params.to_json, headers: headers
      }.to change(HouseworkLog, :count).by(1)

      expect(response).to have_http_status(:created)
    end

    it "バリデーションエラー時に422を返す" do
      invalid_params = { housework_log: { category: "", minutes: 30 } }
      post api_v1_housework_logs_path, params: invalid_params.to_json, headers: headers
      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
