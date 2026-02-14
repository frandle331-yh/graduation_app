class CreateHouseworkTemplates < ActiveRecord::Migration[8.1]
  def change
    create_table :housework_templates do |t|
      t.references :user,      null: false, foreign_key: true
      t.references :household, null: true,  foreign_key: true
      t.string  :title,    null: false
      t.integer :category, null: false, default: 0
      t.integer :minutes
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    add_index :housework_templates, [:user_id, :position]
  end
end
