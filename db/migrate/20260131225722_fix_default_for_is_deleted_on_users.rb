class FixDefaultForIsDeletedOnUsers < ActiveRecord::Migration[8.1]
  def change
    change_column_default :users, :is_deleted, from: nil, to: false
    change_column_null :users, :is_deleted, false, false
  end
end
