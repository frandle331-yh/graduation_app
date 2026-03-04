class AddCompositeIndexesToHouseworkLogs < ActiveRecord::Migration[8.1]
  def change
    # ダッシュボード: household_id + 期間フィルタの複合クエリを高速化
    add_index :housework_logs, [:household_id, :performed_on],
              name: "index_housework_logs_on_household_id_and_performed_on"

    # ログ一覧: user_id + 期間フィルタの複合クエリを高速化
    add_index :housework_logs, [:user_id, :performed_on],
              name: "index_housework_logs_on_user_id_and_performed_on"

    # 世帯テーブル: created_by_id 外部キーのルックアップ
    add_index :households, :created_by_id,
              name: "index_households_on_created_by_id"
  end
end
