require "rails_helper"

RSpec.describe "HouseworkTemplates", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  describe "GET /housework_templates" do
    context "未ログインの場合" do
      it "ログインページにリダイレクトする" do
        get housework_templates_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログイン済みの場合" do
      before { sign_in user }

      it "正常にレスポンスを返す" do
        get housework_templates_path
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "GET /housework_templates/new" do
    context "未ログインの場合" do
      it "ログインページにリダイレクトする" do
        get new_housework_template_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログイン済みの場合" do
      before { sign_in user }

      it "正常にレスポンスを返す" do
        get new_housework_template_path
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "POST /housework_templates" do
    context "ログイン済みで有効なパラメータの場合" do
      before { sign_in user }

      it "テンプレートを作成してリダイレクトする" do
        expect {
          post housework_templates_path, params: {
            housework_template: { title: "掃除テンプレ", category: "cleaning", minutes: 20 }
          }
        }.to change(HouseworkTemplate, :count).by(1)
        expect(response).to redirect_to(housework_templates_path)
      end
    end

    context "ログイン済みで無効なパラメータの場合" do
      before { sign_in user }

      it "テンプレートを作成せずにフォームを再表示する" do
        expect {
          post housework_templates_path, params: {
            housework_template: { title: "", category: "cleaning", minutes: 20 }
          }
        }.not_to change(HouseworkTemplate, :count)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /housework_templates/:id/edit" do
    context "自分のテンプレートの場合" do
      let(:template) { create(:housework_template, user: user) }

      before { sign_in user }

      it "正常にレスポンスを返す" do
        get edit_housework_template_path(template)
        expect(response).to have_http_status(:ok)
      end
    end

    context "他ユーザーのテンプレートの場合" do
      let(:template) { create(:housework_template, user: other_user) }

      before { sign_in user }

      it "404を返す（find が失敗する）" do
        expect {
          get edit_housework_template_path(template)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "PATCH /housework_templates/:id" do
    context "自分のテンプレートを更新する場合" do
      let(:template) { create(:housework_template, user: user) }

      before { sign_in user }

      it "更新してリダイレクトする" do
        patch housework_template_path(template), params: {
          housework_template: { title: "更新したテンプレ" }
        }
        expect(response).to redirect_to(housework_templates_path)
        expect(template.reload.title).to eq("更新したテンプレ")
      end
    end
  end

  describe "DELETE /housework_templates/:id" do
    context "自分のテンプレートを削除する場合" do
      let!(:template) { create(:housework_template, user: user) }

      before { sign_in user }

      it "削除してリダイレクトする" do
        expect {
          delete housework_template_path(template)
        }.to change(HouseworkTemplate, :count).by(-1)
        expect(response).to redirect_to(housework_templates_path)
      end
    end
  end

  describe "POST /housework_templates/:id/use" do
    context "ログイン済みで自分のテンプレートの場合" do
      let(:template) { create(:housework_template, user: user) }

      before { sign_in user }

      it "ログを1件作成してリダイレクトする" do
        expect {
          post use_housework_template_path(template)
        }.to change(HouseworkLog, :count).by(1)
        expect(response).to redirect_to(housework_logs_path)
      end
    end

    context "未ログインの場合" do
      let(:template) { create(:housework_template, user: user) }

      it "ログインページにリダイレクトする" do
        post use_housework_template_path(template)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
