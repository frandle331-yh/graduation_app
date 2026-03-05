require "rails_helper"

RSpec.describe GuestCleanupJob, type: :job do
  describe "#perform" do
    it "7日以上前のゲストをソフトデリートする" do
      old_guest = create(:user, email: "guest_abc123@kajimate.example.com", created_at: 8.days.ago)
      new_guest = create(:user, email: "guest_def456@kajimate.example.com", created_at: 1.day.ago)
      regular_user = create(:user, email: "user@example.com", created_at: 30.days.ago)

      described_class.perform_now

      expect(old_guest.reload.withdrawn_at).to be_present
      expect(new_guest.reload.withdrawn_at).to be_nil
      expect(regular_user.reload.withdrawn_at).to be_nil
    end

    it "既にソフトデリート済みのゲストは影響しない" do
      withdrawn_guest = create(:user, :withdrawn, email: "guest_old@kajimate.example.com", created_at: 10.days.ago)
      original_withdrawn_at = withdrawn_guest.withdrawn_at

      described_class.perform_now

      expect(withdrawn_guest.reload.withdrawn_at).to eq(original_withdrawn_at)
    end
  end
end
