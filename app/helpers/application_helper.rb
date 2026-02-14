module ApplicationHelper
  CATEGORY_ICONS = {
    "cleaning"    => "🧹",
    "laundry"     => "👕",
    "cooking"     => "🍳",
    "dishwashing" => "🍽️",
    "shopping"    => "🛒",
    "childcare"   => "👶",
    "other"       => "📝"
  }.freeze

  def category_icon(category)
    CATEGORY_ICONS[category.to_s] || "📝"
  end
end
