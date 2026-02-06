class HouseworkLog < ApplicationRecord
  belongs_to :user

  validates :title, presence: true, length: { maximum: 50 }
  validates :category, presence: true
  validates :performed_on, presence: true
  validates :minutes, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
end
