require "rails_helper"

RSpec.describe "ゲストログイン", type: :system do
  it "ゲストとしてログインできる" do
    visit root_path

    click_button "ゲストとして試す →"

    expect(page).to have_content("ゲストとしてログインしました")
    expect(page).to have_current_path(dashboard_path)
  end
end
