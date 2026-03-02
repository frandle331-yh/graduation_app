require 'rails_helper'

RSpec.describe Household, type: :model do
  describe "バリデーション" do
    subject { build(:household) }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:invitation_code) }
    it { should validate_uniqueness_of(:invitation_code) }
  end

  describe "アソシエーション" do
    it { should belong_to(:creator).class_name("User") }
    it { should have_many(:household_members).dependent(:destroy) }
    it { should have_many(:users).through(:household_members) }
    it { should have_many(:housework_logs).dependent(:destroy) }
  end

  describe "招待コードのユニーク制約" do
    let!(:existing_household) { create(:household, invitation_code: "ABCD1234") }

    it "同じ招待コードは保存できない" do
      duplicate = build(:household, invitation_code: "ABCD1234")
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:invitation_code]).to be_present
    end
  end
end
