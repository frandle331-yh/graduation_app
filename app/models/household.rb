class Household < ApplicationRecord
  belongs_to :creator, class_name: "User", foreign_key: :created_by_id

  has_many :household_members, dependent: :destroy
  has_many :users, through: :household_members

  has_many :housework_logs, dependent: :destroy

  validates :name, presence: true
  validates :invitation_code, presence: true, uniqueness: true
end
