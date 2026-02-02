class AddDeviseToUsers < ActiveRecord::Migration[8.1]
  def change
    # 既存 users テーブルに Devise 必須カラムはすでに存在するため
    # この migration では何もしない
  end
end
