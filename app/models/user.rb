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
end
