require 'rails_helper'

RSpec.describe HouseworkTemplate, type: :model do
  describe "バリデーション" do
    it { should validate_presence_of(:title) }
    it { should validate_length_of(:title).is_at_most(50) }
    it { should validate_presence_of(:category) }
    it { should validate_numericality_of(:position).only_integer.is_greater_than_or_equal_to(0) }
  end

  describe "minutesのバリデーション" do
    it "0は有効" do
      template = build(:housework_template, minutes: 0)
      expect(template).to be_valid
    end

    it "1440は有効" do
      template = build(:housework_template, minutes: 1440)
      expect(template).to be_valid
    end

    it "1441は無効" do
      template = build(:housework_template, minutes: 1441)
      expect(template).not_to be_valid
    end

    it "nilは有効（任意項目）" do
      template = build(:housework_template, minutes: nil)
      expect(template).to be_valid
    end
  end

  describe "アソシエーション" do
    it { should belong_to(:user) }
    it { should belong_to(:household).optional }
  end

  describe "#to_log" do
    let(:user)      { create(:user) }
    let(:household) { create(:household) }
    let(:template)  { create(:housework_template, user: user, title: "掃除機", category: :cleaning, minutes: 20) }

    subject { template.to_log(user: user, household: household) }

    it "HouseworkLogのインスタンスを返す" do
      expect(subject).to be_a(HouseworkLog)
    end

    it "テンプレートの情報が正しくコピーされている" do
      expect(subject.title).to eq("掃除機")
      expect(subject.category).to eq("cleaning")
      expect(subject.minutes).to eq(20)
    end

    it "performed_onが今日の日付になっている" do
      expect(subject.performed_on).to eq(Time.zone.today)
    end

    it "指定したユーザーと世帯が設定されている" do
      expect(subject.user).to eq(user)
      expect(subject.household).to eq(household)
    end

    it "この時点ではまだ保存されていない" do
      expect(subject).to be_new_record
    end
  end

  describe "スコープ" do
    describe ".ordered" do
      let(:user) { create(:user) }

      it "positionの昇順で返す" do
        t2 = create(:housework_template, user: user, position: 2)
        t0 = create(:housework_template, user: user, position: 0)
        t1 = create(:housework_template, user: user, position: 1)

        expect(user.housework_templates.ordered).to eq([ t0, t1, t2 ])
      end
    end
  end
end
