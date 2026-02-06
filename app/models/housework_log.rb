class HouseworkLog < ApplicationRecord
  belongs_to :user

  validates :title, presence: true, length: { maximum: 50 }
  validates :category, presence: true
  validates :performed_on, presence: true
  validates :minutes, presence: true
  validates :minutes, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 1440
  }, allow_blank: true


end
