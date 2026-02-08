class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  scope :active, -> { where(is_deleted: false) }

  validates :nickname, presence: true, length: { maximum: 20 }

  has_many :household_members, dependent: :destroy
  has_many :households, through: :household_members
  has_many :housework_logs, dependent: :destroy


  def active_for_authentication?
    super && !is_deleted
  end

  def inactive_message
    is_deleted ? :deleted_account : super
  end
end
