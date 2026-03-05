require 'rails_helper'

RSpec.describe User, type: :model do
  describe "バリデーション" do
    it { should validate_presence_of(:nickname) }
    it { should validate_length_of(:nickname).is_at_most(20) }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
  end

  describe "アソシエーション" do
    it { should have_many(:household_members).dependent(:destroy) }
    it { should have_many(:households).through(:household_members) }
    it { should have_many(:housework_logs).dependent(:destroy) }
    it { should have_many(:housework_templates).dependent(:destroy) }
  end

  describe "スコープ" do
    describe ".active" do
      let!(:active_user)    { create(:user) }
      let!(:withdrawn_user) { create(:user, :withdrawn) }

      it "退会していないユーザーのみ返す" do
        expect(User.active).to include(active_user)
        expect(User.active).not_to include(withdrawn_user)
      end
    end
  end

  describe "#active_for_authentication?" do
    context "退会していないユーザー" do
      let(:user) { build(:user) }

      it "trueを返す" do
        expect(user.active_for_authentication?).to be true
      end
    end

    context "退会済みユーザー" do
      let(:user) { build(:user, :withdrawn) }

      it "falseを返す" do
        expect(user.active_for_authentication?).to be false
      end
    end
  end

  describe "#inactive_message" do
    context "退会済みユーザー" do
      let(:user) { build(:user, :withdrawn) }

      it ":deleted_accountを返す" do
        expect(user.inactive_message).to eq(:deleted_account)
      end
    end

    context "退会していないユーザー" do
      let(:user) { build(:user) }

      it "デフォルトのメッセージを返す" do
        expect(user.inactive_message).to eq(:inactive)
      end
    end
  end

  describe "#achievement_badges" do
    let(:user) { create(:user) }

    it "全バッジの一覧を返す" do
      badges = user.achievement_badges
      expect(badges).to be_an(Array)
      expect(badges.size).to eq(BadgeCalculator::BADGES.size)
      expect(badges.first).to include(:key, :icon, :title, :description, :earned)
    end

    context "家事ログが1件もない場合" do
      it "全バッジが未獲得である" do
        badges = user.achievement_badges
        expect(badges.none? { |b| b[:earned] }).to be true
      end
    end

    context "家事ログが1件ある場合" do
      before { create(:housework_log, user: user) }

      it "「はじめの一歩」バッジを獲得している" do
        badges = user.achievement_badges
        first_log = badges.find { |b| b[:key] == :first_log }
        expect(first_log[:earned]).to be true
      end
    end

    context "4カテゴリ以上で記録がある場合" do
      before do
        %i[cleaning laundry cooking dishwashing].each do |cat|
          create(:housework_log, user: user, category: cat)
        end
      end

      it "「オールラウンダー」バッジを獲得している" do
        badge = user.achievement_badges.find { |b| b[:key] == :all_rounder }
        expect(badge[:earned]).to be true
      end
    end
  end

  describe "#earned_badges" do
    let(:user) { create(:user) }

    it "獲得済みバッジのみ返す" do
      create(:housework_log, user: user)
      earned = user.earned_badges
      expect(earned).to all(include(earned: true))
      expect(earned.map { |b| b[:key] }).to include(:first_log)
    end
  end
end
