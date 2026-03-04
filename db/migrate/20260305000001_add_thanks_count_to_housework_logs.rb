class AddThanksCountToHouseworkLogs < ActiveRecord::Migration[8.1]
  def change
    add_column :housework_logs, :thanks_count, :integer, default: 0, null: false
  end
end
