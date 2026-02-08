class HouseholdMember < ApplicationRecord
  belongs_to :household
  belongs_to :user

  enum :role, { owner: 0, member: 1 }


  validates :role, presence: true
end
