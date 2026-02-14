class HouseworkTemplate < ApplicationRecord
  belongs_to :user
  belongs_to :household, optional: true

  validates :title,    presence: true, length: { maximum: 50 }
  validates :category, presence: true
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :minutes,
    numericality: {
      only_integer: true,
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: 1440
    }, allow_blank: true

  enum :category, {
    cleaning:    0,
    laundry:     1,
    cooking:     2,
    dishwashing: 3,
    shopping:    4,
    childcare:   5,
    other:       99
  }

  scope :ordered, -> { order(:position, :created_at) }

  # テンプレートからログを生成する
  def to_log(user:, household:)
    HouseworkLog.new(
      title:        title,
      category:     category,
      minutes:      minutes,
      performed_on: Time.zone.today,
      user:         user,
      household:    household
    )
  end
end
