class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :nickname, presence: true, length: { maximum: 20 }

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
