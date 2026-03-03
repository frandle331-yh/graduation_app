require "rails_helper"

RSpec.describe "Households", type: :request do
  let(:user) { create(:user) }

  describe "GET /household/new" do
    context "未ログインの場合" do
      it "ログインページにリダイレクトする" do
        get new_household_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログイン済みで世帯未参加の場合" do
      before { sign_in user }

      it "正常にレスポンスを返す" do
        get new_household_path
        expect(response).to have_http_status(:ok)
      end
    end

    context "ログイン済みですでに世帯に参加している場合" do
      let(:household) { create(:household, creator: user) }

      before do
        sign_in user
        create(:household_member, household: household, user: user, role: :owner)
      end

      it "世帯ページにリダイレクトする" do
        get new_household_path
        expect(response).to redirect_to(household_path)
      end
    end
  end

  describe "POST /household" do
    context "ログイン済みで有効なパラメータの場合" do
      before { sign_in user }

      it "世帯を作成してリダイレクトする" do
        expect {
          post household_path, params: { household: { name: "テスト家族" } }
        }.to change(Household, :count).by(1)
        expect(response).to redirect_to(household_path)
      end
    end

    context "ログイン済みで無効なパラメータの場合" do
      before { sign_in user }

      it "世帯を作成せずにフォームを再表示する" do
        expect {
          post household_path, params: { household: { name: "" } }
        }.not_to change(Household, :count)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /household" do
    context "未ログインの場合" do
      it "ログインページにリダイレクトする" do
        get household_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログイン済みで世帯に参加している場合" do
      let(:household) { create(:household, creator: user) }

      before do
        sign_in user
        create(:household_member, household: household, user: user, role: :owner)
      end

      it "正常にレスポンスを返す" do
        get household_path
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "GET /household/join" do
    context "未ログインの場合" do
      it "ログインページにリダイレクトする" do
        get join_household_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログイン済みで世帯未参加の場合" do
      before { sign_in user }

      it "正常にレスポンスを返す" do
        get join_household_path
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "POST /household/join" do
    context "正しい招待コードの場合" do
      let(:household) { create(:household) }

      before { sign_in user }

      it "世帯に参加してリダイレクトする" do
        expect {
          post join_household_path, params: { invitation_code: household.invitation_code }
        }.to change(HouseholdMember, :count).by(1)
        expect(response).to redirect_to(household_path)
      end
    end

    context "存在しない招待コードの場合" do
      before { sign_in user }

      it "参加せずにフォームを再表示する" do
        expect {
          post join_household_path, params: { invitation_code: "XXXXXXXX" }
        }.not_to change(HouseholdMember, :count)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
