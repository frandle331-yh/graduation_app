class RemoveIsDeletedFromUsers < ActiveRecord::Migration[8.1]
  def change
    remove_column :users, :is_deleted, :boolean
  end
end
