require "rails_helper"

RSpec.describe HouseworkLogFilter do
  let(:user) { create(:user) }
  let(:household) { nil }

  describe "#scope" do
    before do
      create(:housework_log, user: user, category: :cleaning, performed_on: Date.current, title: "掃除機")
      create(:housework_log, user: user, category: :cooking, performed_on: 1.month.ago, title: "夕食準備")
    end

    it "全期間ではすべてのログを返す" do
      filter = described_class.new(user: user, household: household, params: { period: "all" })
      expect(filter.scope.count).to eq(2)
    end

    it "今週のログをフィルタできる" do
      filter = described_class.new(user: user, household: household, params: { period: "week" })
      expect(filter.scope.count).to eq(1)
    end

    it "カテゴリでフィルタできる" do
      filter = described_class.new(user: user, household: household, params: { category: "cleaning" })
      expect(filter.scope.count).to eq(1)
    end

    it "キーワードでフィルタできる" do
      filter = described_class.new(user: user, household: household, params: { keyword: "掃除" })
      expect(filter.scope.count).to eq(1)
    end
  end

  describe "#stats" do
    before do
      create(:housework_log, user: user, category: :cleaning, minutes: 30, performed_on: Date.current)
      create(:housework_log, user: user, category: :cleaning, minutes: 20, performed_on: Date.current)
    end

    it "集計情報を返す" do
      filter = described_class.new(user: user, household: household, params: {})
      stats = filter.stats
      expect(stats[:total_count]).to eq(2)
      expect(stats[:total_minutes]).to eq(50)
      expect(stats[:top_category]).to eq("cleaning")
    end
  end

  describe "#daily_summaries" do
    before do
      8.times do |i|
        create(:housework_log, user: user, minutes: 10, performed_on: i.days.ago)
      end
    end

    it "デフォルトで直近7件に絞る" do
      filter = described_class.new(user: user, household: household, params: {})
      expect(filter.daily_summaries.size).to eq(7)
    end

    it "allモードで全件返す" do
      filter = described_class.new(user: user, household: household, params: { daily: "all" })
      expect(filter.daily_summaries.size).to eq(8)
    end
  end
end
