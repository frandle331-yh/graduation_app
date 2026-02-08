class AddWithdrawnAtToUsers < ActiveRecord::Migration[8.1]
  def up
    add_column :users, :withdrawn_at, :datetime
    add_index :users, :withdrawn_at

    execute <<~SQL
      UPDATE users
      SET withdrawn_at = NOW()
      WHERE is_deleted = TRUE AND withdrawn_at IS NULL
    SQL
  end

  def down
    remove_index :users, :withdrawn_at
    remove_column :users, :withdrawn_at
  end
end
