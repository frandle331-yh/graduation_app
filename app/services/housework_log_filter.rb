# frozen_string_literal: true

# 家事ログの絞り込み・集計ロジックをコントローラから分離する
class HouseworkLogFilter
  attr_reader :period, :selected_category, :keyword, :daily_mode

  def initialize(user:, household:, params:)
    @user = user
    @household = household
    @period = params[:period].presence || "all"
    @selected_category = params[:category].presence
    @keyword = params[:keyword].to_s.strip.presence
    @daily_mode = params[:daily].presence || "top7"
  end

  def scope
    @scope ||= begin
      s = HouseworkLog.accessible_by(@user, @household)
      s = apply_period(s)
      s = apply_category(s)
      s = apply_keyword(s)
      s
    end
  end

  def daily_summaries
    @daily_summaries ||= begin
      daily_hash = scope.group(:performed_on).sum(:minutes)
      daily_sorted = daily_hash.sort_by { |date, _| date }.reverse

      if @daily_mode == "all"
        daily_sorted.to_h
      else
        daily_sorted.first(7).to_h
      end
    end
  end

  def stats
    @stats ||= {
      total_count: scope.count,
      total_minutes: scope.sum(:minutes),
      top_category: scope.group(:category).count.max_by { |_, v| v }&.first,
      category_summaries: scope.group(:category).sum(:minutes)
    }
  end

  private

  def apply_period(s)
    today = Time.zone.today

    case @period
    when "week"
      s.where(performed_on: today.beginning_of_week..today.end_of_week)
    when "month"
      s.where(performed_on: today.beginning_of_month..today.end_of_month)
    else
      @period = "all"
      s
    end
  end

  def apply_category(s)
    if @selected_category.present? && HouseworkLog.categories.key?(@selected_category)
      s.where(category: HouseworkLog.categories[@selected_category])
    else
      @selected_category = nil
      s
    end
  end

  def apply_keyword(s)
    if @keyword.present?
      escaped = @keyword.gsub(/[\\%_]/) { |c| "\\#{c}" }
      s.where("title ILIKE ?", "%#{escaped}%")
    else
      s
    end
  end
end
