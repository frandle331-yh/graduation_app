require "rails_helper"

RSpec.describe "ダッシュボード", type: :system do
  let(:user) { create(:user) }

  before { login_as(user, scope: :user) }

  it "ダッシュボードにアクセスできる" do
    visit dashboard_path

    expect(page).to have_content("連続記録中")
    expect(page).to have_content("今週のまとめ")
    expect(page).to have_content("達成バッジ")
    expect(page).to have_content("家事ログ一覧を見る")
  end

  it "家事ログがあると統計が表示される" do
    create(:housework_log, user: user, performed_on: Date.current, minutes: 30, category: :cooking)
    create(:housework_log, user: user, performed_on: Date.current, minutes: 20, category: :cleaning)

    visit dashboard_path

    expect(page).to have_content("50") # 合計時間
    expect(page).to have_content("2")  # 記録回数
  end

  it "達成バッジが表示される" do
    create(:housework_log, user: user, performed_on: Date.current)

    visit dashboard_path

    expect(page).to have_content("はじめの一歩")
    expect(page).to have_content("1 / 10 獲得")
  end

  it "期間切り替えができる" do
    visit dashboard_path(period: "month")
    expect(page).to have_content("今月")
  end
end
