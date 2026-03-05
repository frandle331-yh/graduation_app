require "rails_helper"

RSpec.describe "Api::V1::Dashboard", type: :request do
  let(:user) { create(:user) }
  let(:token) { user.generate_api_token! }
  let(:headers) { { "Authorization" => "Bearer #{token}" } }

  describe "GET /api/v1/dashboard" do
    before do
      create(:housework_log, user: user, performed_on: Date.current, minutes: 30)
    end

    it "ダッシュボードデータを返す" do
      get api_v1_dashboard_path, headers: headers
      expect(response).to have_http_status(:ok)

      json = response.parsed_body
      expect(json).to include(
        "period", "period_label", "streak",
        "total_minutes", "total_count",
        "weekly_summary", "earned_badge_count"
      )
      expect(json["total_minutes"]).to eq(30)
      expect(json["total_count"]).to eq(1)
    end

    it "期間を指定できる" do
      get api_v1_dashboard_path, params: { period: "month" }, headers: headers
      expect(response.parsed_body["period"]).to eq("month")
    end
  end
end
