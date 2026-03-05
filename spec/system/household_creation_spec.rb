require "rails_helper"

RSpec.describe "世帯作成", type: :system do
  let(:user) { create(:user) }

  before { login_as(user, scope: :user) }

  it "世帯を作成できる" do
    visit new_household_path

    fill_in "household[name]", with: "テスト家族"
    click_button "作成"

    expect(page).to have_content("テスト家族")
    expect(user.households.count).to eq(1)
  end
end
