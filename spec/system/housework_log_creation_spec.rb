require "rails_helper"

RSpec.describe "家事ログ作成", type: :system do
  let(:user) { create(:user) }

  before { login_as(user, scope: :user) }

  it "新しい家事ログを作成できる" do
    visit new_housework_log_path

    select "掃除", from: "housework_log[category]"
    fill_in "housework_log[title]", with: "リビング掃除機"
    fill_in "housework_log[minutes]", with: "30"
    click_button "登録する"

    expect(page).to have_content("家事ログを登録しました")
    expect(user.housework_logs.count).to eq(1)
    expect(user.housework_logs.last.title).to eq("リビング掃除機")
  end

  it "タイトル未入力でもカテゴリ名が自動セットされる" do
    visit new_housework_log_path

    select "料理", from: "housework_log[category]"
    fill_in "housework_log[minutes]", with: "45"
    click_button "登録する"

    expect(page).to have_content("家事ログを登録しました")
    expect(user.housework_logs.last.title).to eq("料理")
  end
end
