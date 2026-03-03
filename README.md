# KajiMate 🏠

> ふたりの家事を、データで見える化する。

**🔗 アプリURL：** https://kajimate.com
**🎬 ゲストログイン：** ログインページの「ゲストとして試す」からすぐに試せます

---

## 📌 サービス概要

同居するカップル・夫婦の「家事分担の偏り」を、データで可視化するWebアプリです。

「私ばっかり家事してる」「ちゃんとやってるのに伝わらない」——こういったすれ違いは、
主観と感情によるものがほとんどです。

KajiMateは **「誰が・いつ・何をやったか」という事実を記録・蓄積** することで、
感情論に陥らず、冷静に分担を見直せる仕組みを提供します。

---

## 🖼️ スクリーンショット

| トップページ | ダッシュボード | 家事ログ一覧 |
|---|---|---|
| （画像を追加） | （画像を追加） | （画像を追加） |

---

## 💡 制作の背景・解決したい課題

共働きが主流となった現代、家事分担は多くのカップル・夫婦にとって悩みの種です。

既存の家事アプリを調査したところ、多くは **「やるべき家事を管理するタスク型」** でした。
「やった家事の実績を継続的に蓄積・分析する」ことに特化したアプリは少なく、ここに優位性があると判断しました。

また、これから自身が同居生活を始めるにあたり、
「データで話し合える仕組み」を自分で作りたいという実体験からの動機もあります。

---

## ✨ 主な機能

### ワンタップ記録（テンプレート機能）
よく使う家事をテンプレートとして登録しておくと、タップ1回で今日の家事を記録できます。
カテゴリ・所要時間も事前設定でき、毎日の記録コストを最小化します。

### ダッシュボード（期間切り替え対応）
今週・今月・全期間を切り替えて、家事の実績を一目で把握できます。
- **棒グラフ**：日別の家事時間推移
- **ドーナツグラフ**：カテゴリ別の家事量・ふたりの貢献度比較

### 家事ログ一覧・絞り込み・検索
期間・カテゴリ・並び順での絞り込みに加え、タイトルのオートコンプリート検索に対応。
ページネーションで大量のデータも快適に閲覧できます。

### 世帯機能・招待コード参加
世帯を作成するとランダムな8桁の招待コードが発行されます。
パートナーはそのコードを入力するだけで世帯に参加でき、貢献度の比較が可能になります。

### Googleログイン対応
メールアドレス登録に加え、Googleアカウントによるログインに対応しています。

### ゲストログイン
登録不要でアプリをすぐに体験できます。採用担当者の方もぜひお試しください。

---

## 🛠️ 技術スタック

| カテゴリ | 技術 |
|---|---|
| バックエンド | Ruby on Rails 8.1 |
| フロントエンド | Hotwire（Turbo / Stimulus）|
| 認証 | Devise / OmniAuth（Google OAuth2）|
| データベース | PostgreSQL |
| グラフ描画 | Chart.js |
| インフラ | Render |
| DB ホスティング | Neon |
| CI | GitHub Actions（RSpec / Rubocop / Brakeman / bundler-audit）|
| テスト | RSpec / FactoryBot / shoulda-matchers |

### 技術選定の理由

**Rails + Hotwire を選んだ理由**
画面遷移が中心のアプリのため、ReactによるSPA化は過剰と判断しました。
HotwireのTurboを活用することで、フルページリロードなしの快適なUXを、余分な複雑さなしに実現しています。

**PostgreSQL を選んだ理由**
家事ログの日次・週次・月次集計など、集計クエリが多いため、SQLの集計処理に強いPostgreSQLを採用しました。

---

## 🗄️ データベース設計（ER図）

[![ER図](https://i.gyazo.com/ea8fa4768a2a5aa4203b0dc0afc22168.png)](https://gyazo.com/ea8fa4768a2a5aa4203b0dc0afc22168)

### テーブル構成

| テーブル | 役割 |
|---|---|
| `users` | ユーザー情報・退会管理（`withdrawn_at`によるソフトデリート）・OmniAuth対応（`provider` / `uid`）|
| `households` | 世帯情報・招待コード管理 |
| `household_members` | 世帯とユーザーの中間テーブル（role: owner / member） |
| `housework_logs` | 家事の実行記録（タイトル・カテゴリ・実施日・所要時間） |
| `housework_templates` | ワンタップ記録用テンプレート（タイトル・カテゴリ・所要時間・並び順） |

---

## 🎨 画面遷移図

- Figma: https://www.figma.com/design/SRDbYkKRLm6Y2Mv7HRPuek/Untitled?node-id=0-1&t=3wupgnAaxwRG0xw1-1

---

## 🔍 実装で工夫したポイント

### 1. トランザクション処理による世帯作成の整合性担保

世帯作成時に `Household` レコードと `HouseholdMember` レコードを同時に作成する必要があります。
どちらか一方の保存に失敗した場合にデータが中途半端な状態にならないよう、`ActiveRecord::Base.transaction` を使って原子的に処理しています。

```ruby
Household.transaction do
  @household.save!
  HouseholdMember.create!(household: @household, user: current_user, role: :owner)
end
```

### 2. ソフトデリートによる退会実装

ユーザーが退会してもデータを物理削除せず、`withdrawn_at` にタイムスタンプを記録する設計にしました。
Deviseの `active_for_authentication?` をオーバーライドすることで、退会済みユーザーのログインを防ぎつつ、関連データの整合性を維持しています。

```ruby
def active_for_authentication?
  super && withdrawn_at.nil?
end
```

### 3. Turbo + OmniAuth の競合解消

Rails 8 の Hotwire（Turbo）環境では、`button_to` が生成するPOSTフォームをTurboがXHRとしてインターセプトするため、`omniauth-rails_csrf_protection` のCSRF検証が失敗します。
GoogleログインボタンのみTurboを無効化（`data: { turbo: false }`）することで解消しました。

```erb
<%= button_to user_google_oauth2_omniauth_authorize_path,
      method: :post, data: { turbo: false } do %>
  Googleでログイン
<% end %>
```

### 4. `current_household` のメモ化

全リクエストで共通して使う `current_household` は `@current_household ||=` でメモ化し、
同一リクエスト内での重複クエリを防いでいます。

```ruby
def current_household
  return nil unless current_user
  @current_household ||= current_user.households.order(:id).first
end
```

### 5. Chart.js によるダッシュボードの可視化

コントローラー側でRubyの集計処理を行い、ビューで `to_json` を介してChart.jsに渡す設計にしました。
集計ロジックをコントローラーに閉じ込めることで、ビューをシンプルに保っています。

### 6. オートコンプリート検索

StimulusコントローラーとカスタムAPIエンドポイントを組み合わせ、家事ログのタイトル検索にオートコンプリートを実装しました。
入力のたびにデバウンスでAPIを叩き、サジェストリストをDOMに反映します。

---

## 📊 競合サービスとの比較

| アプリ | 主目的 | KajiMateとの違い |
|---|---|---|
| CAJICO | ポイント・感謝スタンプ | 実績データの継続分析には不向き |
| PikaPika | 掃除スケジュール管理 | 掃除限定・貢献度比較なし |
| ペアワーク | 家事時間の時給換算 | 記録コストが高く継続しづらい |
| **KajiMate** | **実績ログの蓄積・分析** | **ワンタップ記録 × データ可視化に特化** |

---

## 🚀 ローカル環境での起動手順

```bash
# リポジトリをクローン
git clone https://github.com/frandle331-yh/graduation_app.git
cd graduation_app

# gemのインストール
bundle install

# データベースのセットアップ
bin/rails db:create db:migrate

# サーバー起動
bin/rails server
```

`http://localhost:3000` にアクセスしてください。

**動作環境**
- Ruby 3.2
- Rails 8.1
- PostgreSQL 16

---

## 🗺️ 今後の実装予定

- [ ] **リマインド通知** — 未記録の家事をメールでリマインド（Action Mailer / Solid Queue）
- [ ] **月次レポート** — 月ごとの分担推移をグラフで振り返り
- [ ] **世帯共有テンプレート** — パートナーとテンプレートを共有
- [ ] **テンプレートの並び替え** — ドラッグ&ドロップで並び順を変更

---

## 👤 作者

プログラミングスクール卒業制作として開発。
ポートフォリオ・就職活動用に公開しています。
