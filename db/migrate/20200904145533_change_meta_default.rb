class ChangeMetaDefault < ActiveRecord::Migration[6.0]
  def change
    change_column_default :pins, :meta, {}
  end
end
