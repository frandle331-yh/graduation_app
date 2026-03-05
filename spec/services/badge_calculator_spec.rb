require "rails_helper"

RSpec.describe BadgeCalculator do
  let(:user) { create(:user) }
  subject(:calculator) { described_class.new(user) }

  describe "#all_badges" do
    it "全バッジを返す" do
      expect(calculator.all_badges.size).to eq(10)
    end

    it "各バッジにearnedキーが含まれる" do
      calculator.all_badges.each do |badge|
        expect(badge).to have_key(:earned)
        expect(badge).to have_key(:key)
        expect(badge).to have_key(:icon)
        expect(badge).to have_key(:title)
      end
    end

    context "ログがない場合" do
      it "全バッジが未達成" do
        expect(calculator.earned_badges).to be_empty
      end
    end

    context "1件ログがある場合" do
      before { create(:housework_log, user: user, performed_on: Date.current) }

      it "はじめの一歩バッジを獲得" do
        earned_keys = calculator.earned_badges.map { |b| b[:key] }
        expect(earned_keys).to include(:first_log)
      end
    end

    context "10件ログがある場合" do
      before do
        10.times { |i| create(:housework_log, user: user, performed_on: Date.current - i) }
      end

      it "コツコツ10回バッジを獲得" do
        earned_keys = calculator.earned_badges.map { |b| b[:key] }
        expect(earned_keys).to include(:ten_logs)
      end
    end

    context "4カテゴリ以上で記録がある場合" do
      before do
        %i[cleaning laundry cooking dishwashing].each do |cat|
          create(:housework_log, user: user, category: cat, performed_on: Date.current)
        end
      end

      it "オールラウンダーバッジを獲得" do
        earned_keys = calculator.earned_badges.map { |b| b[:key] }
        expect(earned_keys).to include(:all_rounder)
      end
    end
  end
end
