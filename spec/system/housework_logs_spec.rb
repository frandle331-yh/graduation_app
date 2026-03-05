require "rails_helper"

RSpec.describe "家事ログ一覧", type: :system do
  let(:user) { create(:user) }

  before { login_as(user, scope: :user) }

  it "ログ一覧ページが表示される" do
    create(:housework_log, user: user, title: "リビング掃除", category: :cleaning, minutes: 30)
    create(:housework_log, user: user, title: "夕食準備", category: :cooking, minutes: 45)

    visit housework_logs_path

    expect(page).to have_content("家事ログ")
    expect(page).to have_content("リビング掃除")
    expect(page).to have_content("夕食準備")
  end

  it "ログがない場合は空メッセージが表示される" do
    visit housework_logs_path

    expect(page).to have_content("家事ログはありません")
  end

  it "新規作成ページへのリンクがある" do
    visit housework_logs_path

    expect(page).to have_link("家事を記録", href: new_housework_log_path)
  end
end
