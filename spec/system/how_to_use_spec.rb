require "rails_helper"

RSpec.describe "使い方ページ", type: :system do
  it "未ログインでもアクセスできる" do
    visit how_to_use_path

    expect(page).to have_content("KajiMateの使い方")
  end

  it "4つの機能カードが表示される" do
    visit how_to_use_path

    expect(page).to have_content("ダッシュボード")
    expect(page).to have_content("家事ログ")
    expect(page).to have_content("テンプレート")
    expect(page).to have_content("貢献バランス")
  end

  it "CTAボタンが表示される" do
    visit how_to_use_path

    expect(page).to have_link("新規登録して始める")
    expect(page).to have_link("ログインする")
  end
end
