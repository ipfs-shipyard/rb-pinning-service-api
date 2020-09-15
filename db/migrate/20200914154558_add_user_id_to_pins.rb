class AddUserIdToPins < ActiveRecord::Migration[6.0]
  def change
    add_column :pins, :user_id, :integer, null: false
  end
end
