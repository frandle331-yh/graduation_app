class CreateHouseholdMembers < ActiveRecord::Migration[8.1]
  def change
    create_table :household_members do |t|
      t.references :household, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :role, null: false, default: 1 # 0: owner, 1: member
      t.string :color
      t.datetime :joined_at

      t.timestamps
    end

    add_index :household_members, [:household_id, :user_id], unique: true
  end
end
