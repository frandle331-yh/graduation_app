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
end
