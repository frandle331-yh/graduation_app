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

      it "週次サマリーを表示する" do
        create(:housework_log, user: user, performed_on: Time.zone.today, minutes: 30, category: :cooking)
        create(:housework_log, user: user, performed_on: Time.zone.today, minutes: 20, category: :cleaning)

        get dashboard_path
        expect(response.body).to include("今週のまとめ")
        expect(response.body).to include("記録数")
        expect(response.body).to include("1日あたり平均")
      end

      it "前週比を表示する" do
        create(:housework_log, user: user, performed_on: Time.zone.today, minutes: 30)
        create(:housework_log, user: user, performed_on: 1.week.ago.to_date, minutes: 15)

        get dashboard_path
        expect(response.body).to include("前週比")
      end

      it "データがない場合でも週次サマリーを表示する" do
        get dashboard_path
        expect(response.body).to include("今週のまとめ")
        expect(response.body).to include("最初の一歩を踏み出しましょう")
      end

      it "達成バッジセクションを表示する" do
        get dashboard_path
        expect(response.body).to include("達成バッジ")
        expect(response.body).to include("獲得")
      end

      it "家事ログがあると対応するバッジが解放される" do
        create(:housework_log, user: user, performed_on: Time.zone.today)
        get dashboard_path
        expect(response.body).to include("はじめの一歩")
      end

      it "月間カレンダーを表示する" do
        create(:housework_log, user: user, performed_on: Time.zone.today)
        get dashboard_path
        expect(response.body).to include(Time.zone.today.strftime("%Y年%-m月"))
        expect(response.body).to include("calendar-grid")
      end
    end
  end
end
