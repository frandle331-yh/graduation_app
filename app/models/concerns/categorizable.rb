# frozen_string_literal: true

module Categorizable
  extend ActiveSupport::Concern

  included do
    enum :category, {
      cleaning: 0,
      laundry: 1,
      cooking: 2,
      dishwashing: 3,
      shopping: 4,
      childcare: 5,
      other: 99
    }
  end
end
