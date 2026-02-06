class CreateHouseworkLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :housework_logs do |t|
      t.string :title, null: false
      t.integer :category, null: false, default: 0
      t.date :performed_on, null: false
      t.integer :minutes
      t.text :memo
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
