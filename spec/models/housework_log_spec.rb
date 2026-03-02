require 'rails_helper'

RSpec.describe HouseworkLog, type: :model do
  describe "バリデーション" do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:category) }
    it { should validate_presence_of(:performed_on) }
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
end
