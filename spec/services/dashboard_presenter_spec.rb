require "rails_helper"

RSpec.describe DashboardPresenter do
  let(:user) { create(:user) }
  let(:household) { nil }
  let(:period) { "week" }
  subject(:presenter) { described_class.new(user: user, household: household, period: period) }

  describe "#period_label" do
    it "週を返す" do
      expect(presenter.period_label).to eq("今週")
    end

    context "月指定" do
      let(:period) { "month" }
      it { expect(presenter.period_label).to eq("今月") }
    end

    context "不正な値" do
      let(:period) { "invalid" }
      it "デフォルトで週になる" do
        expect(presenter.period).to eq("week")
      end
    end
  end

  describe "#total_minutes / #total_count" do
    before do
      create(:housework_log, user: user, performed_on: Time.zone.today, minutes: 30)
      create(:housework_log, user: user, performed_on: Time.zone.today, minutes: 20)
    end

    it "合計分数と件数を返す" do
      expect(presenter.total_minutes).to eq(50)
      expect(presenter.total_count).to eq(2)
    end
  end

  describe "#weekly_summary" do
    it "ハッシュを返す" do
      summary = presenter.weekly_summary
      expect(summary).to have_key(:count)
      expect(summary).to have_key(:minutes)
      expect(summary).to have_key(:last_count)
      expect(summary).to have_key(:avg_minutes_per_day)
    end
  end

  describe "#badges" do
    it "バッジ一覧を返す" do
      expect(presenter.badges).to be_an(Array)
      expect(presenter.badges.first).to have_key(:earned)
    end
  end

  describe "#calendar" do
    it "カレンダーデータを返す" do
      cal = presenter.calendar
      expect(cal).to have_key(:month_label)
      expect(cal).to have_key(:first)
      expect(cal).to have_key(:last)
      expect(cal).to have_key(:data)
    end
  end

  describe "#contribution" do
    context "世帯なしの場合" do
      it "nilを返す" do
        expect(presenter.contribution).to be_nil
      end
    end
  end
end
