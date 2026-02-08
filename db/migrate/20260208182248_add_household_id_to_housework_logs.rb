class AddHouseholdIdToHouseworkLogs < ActiveRecord::Migration[8.1]
  def change
    add_reference :housework_logs, :household, null: true, foreign_key: true
  end
end
