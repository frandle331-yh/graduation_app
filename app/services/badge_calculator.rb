# frozen_string_literal: true

# ユーザーの達成バッジを計算する
class BadgeCalculator
  BADGES = [
    { key: :first_log,     icon: "\u{1F331}", title: "はじめの一歩",   description: "初めて家事を記録した",
      condition: ->(s) { s[:total] >= 1 } },
    { key: :ten_logs,      icon: "\u2B50",    title: "コツコツ10回",   description: "家事を10回記録した",
      condition: ->(s) { s[:total] >= 10 } },
    { key: :fifty_logs,    icon: "\u{1F48E}", title: "ベテラン50回",   description: "家事を50回記録した",
      condition: ->(s) { s[:total] >= 50 } },
    { key: :hundred_logs,  icon: "\u{1F451}", title: "家事マスター",   description: "家事を100回記録した",
      condition: ->(s) { s[:total] >= 100 } },
    { key: :streak_3,      icon: "\u{1F525}", title: "3日連続",       description: "3日連続で家事を記録した",
      condition: ->(s) { s[:streak] >= 3 } },
    { key: :streak_7,      icon: "\u{1F3C6}", title: "1週間連続",     description: "7日連続で家事を記録した",
      condition: ->(s) { s[:streak] >= 7 } },
    { key: :streak_30,     icon: "\u{1F3C5}", title: "30日連続",      description: "30日連続で家事を記録した",
      condition: ->(s) { s[:streak] >= 30 } },
    { key: :all_rounder,   icon: "\u{1F308}", title: "オールラウンダー", description: "4種類以上のカテゴリで記録した",
      condition: ->(s) { s[:categories] >= 4 } },
    { key: :time_500,      icon: "\u23F0",    title: "500分の壁",     description: "累計500分以上の家事をこなした",
      condition: ->(s) { s[:minutes] >= 500 } },
    { key: :time_2000,     icon: "\u{1F680}", title: "2000分突破",    description: "累計2000分以上の家事をこなした",
      condition: ->(s) { s[:minutes] >= 2000 } }
  ].freeze

  def initialize(user)
    @user = user
  end

  def all_badges
    stats = compute_stats
    BADGES.map do |badge|
      earned = badge[:condition].call(stats)
      badge.except(:condition).merge(earned: earned)
    end
  end

  def earned_badges
    all_badges.select { |b| b[:earned] }
  end

  private

  def compute_stats
    logs = @user.housework_logs
    {
      total: logs.count,
      streak: StreakCalculator.new(@user).current_streak,
      categories: logs.distinct.count(:category),
      minutes: logs.sum(:minutes)
    }
  end
end
