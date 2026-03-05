require "rails_helper"

RSpec.describe WeeklyReportMailer, type: :mailer do
  describe "#weekly_report" do
    let(:user) { create(:user, nickname: "テスト太郎", email: "test@example.com") }
    let(:mail) { described_class.weekly_report(user) }

    before do
      create(:housework_log, user: user, performed_on: Date.current, minutes: 30, category: :cooking)
      create(:housework_log, user: user, performed_on: Date.current, minutes: 20, category: :cleaning)
    end

    it "正しい宛先に送信する" do
      expect(mail.to).to eq([ "test@example.com" ])
    end

    it "件名にユーザー名を含む" do
      expect(mail.subject).to include("テスト太郎")
      expect(mail.subject).to include("今週の家事レポート")
    end

    it "本文に統計情報を含む" do
      expect(mail.body.encoded).to include("2") # 記録回数
      expect(mail.body.encoded).to include("50") # 合計時間
    end

    it "HTMLとテキストの両方を含む" do
      expect(mail.parts.map(&:content_type)).to include(
        a_string_matching("text/html"),
        a_string_matching("text/plain")
      )
    end
  end
end
