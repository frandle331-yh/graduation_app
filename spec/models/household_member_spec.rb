require 'rails_helper'

RSpec.describe HouseholdMember, type: :model do
  describe "バリデーション" do
    it { should validate_presence_of(:role) }
  end

  describe "アソシエーション" do
    it { should belong_to(:household) }
    it { should belong_to(:user) }
  end

  describe "roleのenum" do
    it "ownerが0" do
      member = build(:household_member, role: :owner)
      expect(member.owner?).to be true
    end

    it "memberが1" do
      member = build(:household_member, role: :member)
      expect(member.member?).to be true
    end
  end

  describe "household_id + user_idのユニーク制約" do
    let(:household) { create(:household) }
    let(:user)      { create(:user) }

    before { create(:household_member, household: household, user: user) }

    it "同じhousehold + userの組み合わせは保存できない" do
      duplicate = build(:household_member, household: household, user: user)
      expect { duplicate.save! }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end
end
