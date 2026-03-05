require "rails_helper"

RSpec.describe StreakCalculator do
  let(:user) { create(:user) }
  subject { described_class.new(user).current_streak }

  context "ログがない場合" do
    it { is_expected.to eq(0) }
  end

  context "今日だけログがある場合" do
    before { create(:housework_log, user: user, performed_on: Date.current) }
    it { is_expected.to eq(1) }
  end

  context "3日連続でログがある場合" do
    before do
      3.times { |i| create(:housework_log, user: user, performed_on: Date.current - i) }
    end
    it { is_expected.to eq(3) }
  end

  context "途中で途切れている場合" do
    before do
      create(:housework_log, user: user, performed_on: Date.current)
      create(:housework_log, user: user, performed_on: Date.current - 1)
      create(:housework_log, user: user, performed_on: Date.current - 3) # 1日空き
    end
    it { is_expected.to eq(2) }
  end

  context "昨日で止まっている場合" do
    before { create(:housework_log, user: user, performed_on: Date.current - 1) }
    it { is_expected.to eq(1) }
  end

  context "2日前で止まっている場合" do
    before { create(:housework_log, user: user, performed_on: Date.current - 2) }
    it { is_expected.to eq(0) }
  end
end
