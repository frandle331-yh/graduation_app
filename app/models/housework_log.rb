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

  enum :category, {
  cleaning: 0,
  laundry: 1,
  cooking: 2,
  dishwashing: 3,
  shopping: 4,
  childcare: 5,
  other: 99
}

  def self.categories_i18n
    categories.keys.index_with do |key|
      I18n.t("enums.housework_log.category.#{key}")
    end
  end


end
