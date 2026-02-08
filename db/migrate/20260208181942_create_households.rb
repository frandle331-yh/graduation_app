class CreateHouseholds < ActiveRecord::Migration[8.1]
  def change
    create_table :households do |t|
      t.string :name, null: false
      t.bigint :created_by_id, null: false
      t.string :invitation_code, null: false
      t.datetime :archived_at

      t.timestamps
    end

    add_index :households, :invitation_code, unique: true
    add_foreign_key :households, :users, column: :created_by_id
  end
end
