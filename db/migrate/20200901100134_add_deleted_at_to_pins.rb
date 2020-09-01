class AddDeletedAtToPins < ActiveRecord::Migration[6.0]
  def change
    add_column :pins, :deleted_at, :datetime
  end
end
