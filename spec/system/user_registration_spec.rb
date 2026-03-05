require "rails_helper"

RSpec.describe "ユーザー登録", type: :system do
  it "新規ユーザーがメールアドレスで登録できる" do
    visit new_user_registration_path

    fill_in "user[nickname]", with: "テスト太郎"
    fill_in "user[email]", with: "new_user@example.com"
    fill_in "user[password]", with: "password123"
    fill_in "user[password_confirmation]", with: "password123"
    click_button "登録する"

    expect(page).to have_current_path(dashboard_path)
    expect(User.find_by(email: "new_user@example.com")).to be_present
  end

  it "バリデーションエラーが表示される" do
    visit new_user_registration_path

    fill_in "user[email]", with: ""
    click_button "登録する"

    expect(page).to have_content("エラー")
  end
end
