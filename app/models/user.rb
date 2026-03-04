class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [ :google_oauth2 ]

  validates :nickname, presence: true, length: { maximum: 20 }

  # Googleログイン時にユーザーを取得 or 作成する
  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email    = auth.info.email
      user.nickname = auth.info.name.truncate(20)
      user.password = Devise.friendly_token[0, 20]
    end
  end

  has_many :household_members, dependent: :destroy
  has_many :households, through: :household_members
  has_many :housework_logs, dependent: :destroy
  has_many :housework_templates, dependent: :destroy


  scope :active, -> { where(withdrawn_at: nil) }

  def active_for_authentication?
    super && withdrawn_at.nil?
  end

  def inactive_message
    withdrawn_at.present? ? :deleted_account : super
  end

  # 今日まで何日連続で家事を記録しているか（最長連続ストリーク）
  def current_streak
    dates = housework_logs
              .where(performed_on: 90.days.ago..Date.current)
              .distinct
              .order(performed_on: :desc)
              .pluck(:performed_on)
    return 0 if dates.empty?

    # 今日 or 昨日から始まっていない場合はストリーク 0
    return 0 unless dates.first >= Date.current - 1

    streak = 1
    dates.each_cons(2) do |newer, older|
      break unless newer - older == 1
      streak += 1
    end
    streak
  end

  # 今週の記録日数（モチベーション表示用）
  def weekly_log_days
    today = Date.current
    housework_logs
      .where(performed_on: today.beginning_of_week..today.end_of_week)
      .distinct
      .count(:performed_on)
  end

  # 達成バッジ一覧を返す
  # 各バッジは { key:, icon:, title:, description:, earned: } のハッシュ
  def achievement_badges
    total = housework_logs.count
    streak = current_streak
    categories_used = housework_logs.distinct.count(:category)
    total_minutes = housework_logs.sum(:minutes)

    BADGES.map do |badge|
      earned = badge[:condition].call(total, streak, categories_used, total_minutes)
      badge.except(:condition).merge(earned: earned)
    end
  end

  def earned_badges
    achievement_badges.select { |b| b[:earned] }
  end

  BADGES = [
    { key: :first_log,     icon: "🌱", title: "はじめの一歩",   description: "初めて家事を記録した",
      condition: ->(total, _, _, _) { total >= 1 } },
    { key: :ten_logs,      icon: "⭐", title: "コツコツ10回",   description: "家事を10回記録した",
      condition: ->(total, _, _, _) { total >= 10 } },
    { key: :fifty_logs,    icon: "💎", title: "ベテラン50回",   description: "家事を50回記録した",
      condition: ->(total, _, _, _) { total >= 50 } },
    { key: :hundred_logs,  icon: "👑", title: "家事マスター",   description: "家事を100回記録した",
      condition: ->(total, _, _, _) { total >= 100 } },
    { key: :streak_3,      icon: "🔥", title: "3日連続",       description: "3日連続で家事を記録した",
      condition: ->(_, streak, _, _) { streak >= 3 } },
    { key: :streak_7,      icon: "🏆", title: "1週間連続",     description: "7日連続で家事を記録した",
      condition: ->(_, streak, _, _) { streak >= 7 } },
    { key: :streak_30,     icon: "🏅", title: "30日連続",      description: "30日連続で家事を記録した",
      condition: ->(_, streak, _, _) { streak >= 30 } },
    { key: :all_rounder,   icon: "🌈", title: "オールラウンダー", description: "4種類以上のカテゴリで記録した",
      condition: ->(_, _, cats, _) { cats >= 4 } },
    { key: :time_500,      icon: "⏰", title: "500分の壁",     description: "累計500分以上の家事をこなした",
      condition: ->(_, _, _, mins) { mins >= 500 } },
    { key: :time_2000,     icon: "🚀", title: "2000分突破",    description: "累計2000分以上の家事をこなした",
      condition: ->(_, _, _, mins) { mins >= 2000 } },
  ].freeze
end
