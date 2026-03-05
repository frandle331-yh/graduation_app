# frozen_string_literal: true

# ユーザーの連続記録日数（ストリーク）を計算する
class StreakCalculator
  def initialize(user)
    @user = user
  end

  def current_streak
    dates = @user.housework_logs
                 .where(performed_on: 90.days.ago..Date.current)
                 .distinct
                 .order(performed_on: :desc)
                 .pluck(:performed_on)
    return 0 if dates.empty?
    return 0 unless dates.first >= Date.current - 1

    streak = 1
    dates.each_cons(2) do |newer, older|
      break unless newer - older == 1
      streak += 1
    end
    streak
  end
end
