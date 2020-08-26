class CreatePins < ActiveRecord::Migration[6.0]
  def change
    create_table :pins do |t|
      t.string :cid
      t.string :name, :limit => 255
      t.string :origins, default: [], array: true
      t.jsonb :meta, null: false, default: '{}'
      t.string :status
      t.string :delegates, default: [], array: true

      t.timestamps
    end
  end
end
