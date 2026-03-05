require 'rails_helper'

RSpec.describe HouseworkLog, type: :model do
  describe "バリデーション" do
    it { should validate_presence_of(:category) }
    it { should validate_presence_of(:performed_on) }

    it "タイトル未入力でもカテゴリ名が自動セットされて有効" do
      log = build(:housework_log, title: "", category: :cooking)
      expect(log).to be_valid
      expect(log.title).to eq("料理")
    end

    it "タイトルが入力済みなら自動補完しない" do
      log = build(:housework_log, title: "特別な料理", category: :cooking)
      expect(log).to be_valid
      expect(log.title).to eq("特別な料理")
    end
  end

  describe "アソシエーション" do
    it { should belong_to(:user) }
    it { should belong_to(:household).optional }
  end

  describe "categoryのenum" do
    it "各カテゴリが正しく定義されている" do
      expect(HouseworkLog.categories.keys).to include(
        "cleaning", "laundry", "cooking", "dishwashing", "shopping", "childcare", "other"
      )
    end
  end

  describe "minutesのバリデーション" do
    it "0は有効" do
      log = build(:housework_log, minutes: 0)
      expect(log).to be_valid
    end

    it "1440（24時間）は有効" do
      log = build(:housework_log, minutes: 1440)
      expect(log).to be_valid
    end

    it "nilは無効（必須項目）" do
      log = build(:housework_log, minutes: nil)
      expect(log).not_to be_valid
    end
  end

  describe ".suggest_titles_for" do
    let(:user) { create(:user) }

    it "過去ログのタイトルとデフォルト候補を返す" do
      create(:housework_log, user: user, title: "お風呂掃除", category: :cleaning)
      create(:housework_log, user: user, title: "お風呂掃除", category: :cleaning)

      result = HouseworkLog.suggest_titles_for(user, "cleaning")
      expect(result.first).to eq("お風呂掃除") # 使用回数が多い順
      expect(result).to include("掃除機かけ")  # デフォルト候補も含む
    end

    it "存在しないカテゴリでも空配列を返す" do
      result = HouseworkLog.suggest_titles_for(user, "nonexistent")
      expect(result).to eq([])
    end
  end
end
