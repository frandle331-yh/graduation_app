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
end
