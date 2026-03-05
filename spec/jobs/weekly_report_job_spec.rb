require "rails_helper"

RSpec.describe WeeklyReportJob, type: :job do
  describe "#perform" do
    it "アクティブなユーザーにメールをキューに入れる" do
      user = create(:user)
      guest = create(:user, email: "guest_abc@kajimate.example.com")
      withdrawn = create(:user, :withdrawn)

      expect {
        described_class.perform_now
      }.to have_enqueued_mail(WeeklyReportMailer, :weekly_report).with(user)
    end

    it "ゲストユーザーには送信しない" do
      guest = create(:user, email: "guest_abc@kajimate.example.com")

      expect {
        described_class.perform_now
      }.not_to have_enqueued_mail(WeeklyReportMailer, :weekly_report)
    end
  end
end
