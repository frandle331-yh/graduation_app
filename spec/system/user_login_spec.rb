require "rails_helper"

RSpec.describe "ユーザーログイン", type: :system do
  let(:user) { create(:user, email: "login@example.com", password: "password123") }

  it "メールアドレスでログインできる" do
    user # create user first
    visit new_user_session_path

    fill_in "user[email]", with: "login@example.com"
    fill_in "user[password]", with: "password123"
    click_button "ログイン"

    expect(page).to have_current_path(dashboard_path)
  end

  it "パスワードが間違っているとエラーになる" do
    user
    visit new_user_session_path

    fill_in "user[email]", with: "login@example.com"
    fill_in "user[password]", with: "wrongpassword"
    click_button "ログイン"

    expect(page).to have_current_path(new_user_session_path)
  end
end
