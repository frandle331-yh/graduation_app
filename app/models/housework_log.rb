class HouseworkLog < ApplicationRecord
  belongs_to :user
  belongs_to :household, optional: true

  before_validation :auto_fill_title

  validates :title, length: { maximum: 50 }
  validates :category, presence: true
  validates :performed_on, presence: true
  validates :minutes, presence: true
  validates :minutes, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 1440
  }, allow_blank: true

  enum :category, {
  cleaning: 0,
  laundry: 1,
  cooking: 2,
  dishwashing: 3,
  shopping: 4,
  childcare: 5,
  other: 99
}

  # カテゴリごとのデフォルトタイトル候補
  TITLE_SUGGESTIONS = {
    "cleaning"    => %w[掃除機かけ 拭き掃除 トイレ掃除 風呂掃除 片付け],
    "laundry"     => %w[洗濯 洗濯物たたみ アイロン クリーニング出し],
    "cooking"     => %w[朝食準備 昼食準備 夕食準備 お弁当作り 作り置き],
    "dishwashing" => %w[食器洗い 食洗機セット キッチン片付け],
    "shopping"    => %w[食材買い出し 日用品買い物 ネットスーパー注文],
    "childcare"   => %w[送り迎え お風呂 寝かしつけ 遊び相手 ご飯の世話],
    "other"       => %w[ゴミ出し 植物の水やり ペットの世話 郵便物整理]
  }.freeze

  # カテゴリ別のタイトル候補を返す（過去ログ + デフォルト候補）
  def self.suggest_titles_for(user, category_key, limit: 8)
    past = user.housework_logs
               .where(category: categories[category_key])
               .group(:title)
               .order(Arel.sql("COUNT(*) DESC"))
               .limit(limit)
               .pluck(:title)

    defaults = TITLE_SUGGESTIONS.fetch(category_key, [])
    (past + defaults).uniq.first(limit)
  end

  def self.categories_i18n
    categories.keys.index_with do |key|
      I18n.t("enums.housework_log.category.#{key}")
    end
  end

  def self.category_label(category_key)
    I18n.t("enums.housework_log.category.#{category_key}", default: category_key.to_s)
  end

  private

  # タイトル未入力時にカテゴリ名を自動セット
  def auto_fill_title
    return if title.present?
    return if category.blank?

    self.title = self.class.category_label(category)
  end
end
